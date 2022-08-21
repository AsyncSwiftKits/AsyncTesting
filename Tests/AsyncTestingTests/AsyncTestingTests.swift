import XCTest
@testable import AsyncTesting

final class AsyncExpectationTests: XCTestCase {
    
    func testDoneExpectation() async throws {
        let delay = 0.01
        let done = asyncExpectation(description: "done")
        Task {
            try await Task.sleep(seconds: delay)
            await done.fulfill()
        }
        try await waitForExpectations([done])
    }
    
    func testDoneMultipleTimesExpectation() async throws {
        let delay = 0.01
        let done = asyncExpectation(description: "done", expectedFulfillmentCount: 3)
        Task {
            try await Task.sleep(seconds: delay)
            await done.fulfill()
        }
        Task {
            try await Task.sleep(seconds: delay)
            await done.fulfill()
        }
        Task {
            try await Task.sleep(seconds: delay)
            await done.fulfill()
        }
        try await waitForExpectations([done])
    }
    
    func testNotDoneInvertedExpectation() async throws {
        let delay = 0.01
        let notDone = asyncExpectation(description: "not done", isInverted: true)
        let task = Task {
            try await Task.sleep(seconds: delay)
            await notDone.fulfill()
        }
        // cancel immediately to prevent fulfill from being run
        task.cancel()
        try await waitForExpectations([notDone], timeout: delay * 2)
    }
    
    func testDoneAndNotDoneInvertedExpectation() async throws {
        let delay = 0.01
        let done = asyncExpectation(description: "done")
        let notDone = asyncExpectation(description: "not done", isInverted: true)
        Task {
            try await Task.sleep(seconds: delay)
            await done.fulfill()
            let task = Task {
                try await Task.sleep(seconds: delay)
                await notDone.fulfill()
            }
            // cancel immediately to prevent fulfill from being run
            task.cancel()
        }
        try await waitForExpectations([notDone], timeout: delay * 2)
        try await waitForExpectations([done])
    }
    
    func testMultipleFulfilledExpectation() async throws {
        let delay = 0.01
        let one = asyncExpectation(description: "one")
        let two = asyncExpectation(description: "two")
        let three = asyncExpectation(description: "three")
        Task {
            try await Task.sleep(seconds: delay)
            await one.fulfill()
        }
        Task {
            try await Task.sleep(seconds: delay)
            await two.fulfill()
        }
        Task {
            try await Task.sleep(seconds: delay)
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
