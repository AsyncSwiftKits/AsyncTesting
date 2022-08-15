# AsyncTesting

Xcode includes XCTest which only has [waitForExpectations(timeout:handler:)] to support async tests. It does not support waiting on a given list of expectations which is necessary for more complex async activity. The original [wait(for:timeout:enforceOrder:)] function does take a list of expectations but is not compatible with modern Swift Concurrency.

The `AsyncExpectation` type in this package supports more feautures for more complex use cases. See the unit tests for reference code.

[waitForExpectations(timeout:handler:)]: https://developer.apple.com/documentation/xctest/xctestcase/1500748-waitforexpectations
[wait(for:timeout:enforceOrder:)]: https://developer.apple.com/documentation/xctest/xctestcase/2806857-wait
