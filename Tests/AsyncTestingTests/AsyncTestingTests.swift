import XCTest
@testable import AsyncTesting

final class AsyncExpectationTests: XCTestCase {
    
    func testDoneExpectation() async throws {
        let done = asyncExpectation(description: "done")
        Task {
            try await Task.sleep(seconds: 0.1)
            await done.fulfill()
        }
        try await waitForExpectations([done])
    }
    
    func testDoneMultipleTimesExpectation() async throws {
        let done = asyncExpectation(description: "done", expectedFulfillmentCount: 3)
        Task {
            try await Task.sleep(seconds: 0.1)
            await done.fulfill()
        }
        Task {
            try await Task.sleep(seconds: 0.1)
            await done.fulfill()
        }
        Task {
            try await Task.sleep(seconds: 0.1)
            await done.fulfill()
        }
        try await waitForExpectations([done])
    }
    
    func testNotDoneInvertedExpectation() async throws {
        let notDone = asyncExpectation(description: "not done", isInverted: true)
        try await waitForExpectations([notDone], timeout: 0.1)
    }
    
    func testDoneAndNotDoneInvertedExpectation() async throws {
        let done = asyncExpectation(description: "done")
        let notDone = asyncExpectation(description: "not done", isInverted: true)
        Task {
            try await Task.sleep(seconds: 0.1)
            await done.fulfill()
        }
        try await waitForExpectations([notDone], timeout: 0.1)
        try await waitForExpectations([done])
    }
    
    func testMultipleFulfilledExpectation() async throws {
        let one = asyncExpectation(description: "one")
        let two = asyncExpectation(description: "two")
        let three = asyncExpectation(description: "three")
        Task {
            try await Task.sleep(seconds: 0.1)
            await one.fulfill()
        }
        Task {
            try await Task.sleep(seconds: 0.1)
            await two.fulfill()
        }
        Task {
            try await Task.sleep(seconds: 0.1)
            await three.fulfill()
        }
        try await waitForExpectations([one, two, three])
    }
    
    func testMultipleAlreadyFulfilledExpectation() async throws {
        let one = asyncExpectation(description: "one")
        let two = asyncExpectation(description: "two")
        let three = asyncExpectation(description: "three")
        await one.fulfill()
        await two.fulfill()
        await three.fulfill()
        
        try await waitForExpectations([one, two, three])
    }
    
}
