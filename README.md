# AsyncTesting

![CI](https://github.com/brennanMKE/AsyncTesting/actions/workflows/ci.yml/badge.svg)
![Nightly](https://github.com/brennanMKE/AsyncTesting/actions/workflows/nightly.yml/badge.svg)

Xcode includes XCTest which only has [waitForExpectations(timeout:handler:)] to support async tests. It does not support waiting on a given list of expectations which is necessary for more complex async activity. The original [wait(for:timeout:enforceOrder:)] function does take a list of expectations but is not compatible with modern Swift Concurrency.

This package extends `XCTestCase` to include the `asyncExpectation` and `waitForExpectations` functions shown below which mimic existing functions to create and wait on expectations. See the unit tests for more reference code.

```swift
let done = asyncExpectation(description: "done")
Task {
    try await Task.sleep(seconds: 0.1)
    await done.fulfill()
}
try await waitForExpectations([done])
```

Alternatively, the `AsyncTesting` type can be used to access the same behavior with static functions which may clearly distinguish these functions from native XCTest functions.

## Testing Async Behavior

Covering async behavior with unit tests must allow the test assertions to be deterministic and not dependent on timing which could vary and cause flaky tests. Testing task cancellation can risk that a task does not return which hangs all unit tests. By using expectations with wait functions effectively tests can be made deterministic and fail quickly when there is a problem. Running unit tests should be as quick as possible so padding flaky tests with longer sleep times should not be necessary. Place expectations and wait calls as key points so that test assertions can be made when appropriate and continue immediately.

> Guarding against async work which never returns is done with expecations and waits with a short timeout. If an async function fails to return it will allow the wait to expire at the timeout and fail the test. Place the async work in a Task so the test is suspended on the wait function. When the wait expires the test will complete with a failure if the async work did not complete as intended.

Often multiple expectations are necessary in different contexts which will not work with what is currently provided with XCTest. Multiple expectations can cause tests run with the iOS simulator to deadlock. The async version of the wait function also will not support more than the most basic use of an expectation. This package was created to overcome the limitations of XCTest. Below are some samples of how to use this package.

For a typical scenario the following test will cover an async function.

```swift
func testDoneExpectation() async throws {
    let delay = 0.01
    let done = asyncExpectation(description: "done")
    Task {
        try await Task.sleep(seconds: delay)
        await done.fulfill()
    }
    await waitForExpectations([done])
}
```

The sleep function should finish quickly in advance of the default 1.0 second timeout. When testing for cancellation, an inverted expectation should be used.

```swift
func testNotDoneInvertedExpectation() async throws {
    let delay = 0.01
    let notDone = asyncExpectation(description: "not done", isInverted: true)
    let task = Task {
        try await Task.sleep(seconds: delay)
        await notDone.fulfill()
    }
    // cancel immediately to prevent fulfill from being run
    task.cancel()
    await waitForExpectations([notDone], timeout: delay * 2)
}
```

Cancelling the parent task will cause the sleep task to receive a `CancellationError` and leave that block without fulfilling the expectation. The wait expires at the timeout and since the expectation is inverted it does not fail the test. If the expectation was fulfilled before the wait expired it would have failed the test. Note: an inverted expectation can be fulfilled but must happen after the timeout of a wait call.

```swift
func testNotYetDoneAndThenDoneExpectation() async throws {
    let delay = 0.01
    let notYetDone = asyncExpectation(description: "not yet done", isInverted: true)
    let done = asyncExpectation(description: "done")
    
    let task = Task {
        await AsyncRunner().run() // sleeps for 2 seconds
        XCTAssertTrue(Task.isCancelled)
        await notYetDone.fulfill() // will timeout before being called
        await done.fulfill() // will be called after cancellation
    }
    
    await waitForExpectations([notYetDone], timeout: delay)
    task.cancel()
    await waitForExpectations([done])
}
```

The test above also cancels the parent task which causes the `run` function to be cancelled but it does not throw. The test assertion confirms the Task is cancelled and then can fulfill the inverted expectation. The first call to wait is for `notYetDone` and has a short timeout sufficient for the immediate cancellation. Then the `done` expectation can be fulfilled and allow the second wait call to complete immediately.

[waitForExpectations(timeout:handler:)]: https://developer.apple.com/documentation/xctest/xctestcase/1500748-waitforexpectations
[wait(for:timeout:enforceOrder:)]: https://developer.apple.com/documentation/xctest/xctestcase/2806857-wait
