# AsyncTesting

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

[waitForExpectations(timeout:handler:)]: https://developer.apple.com/documentation/xctest/xctestcase/1500748-waitforexpectations
[wait(for:timeout:enforceOrder:)]: https://developer.apple.com/documentation/xctest/xctestcase/2806857-wait
