//
//  PusherServiceTests.swift
//  PusherAppTests
//
//  Created by matt naples on 12/16/22.
//

import XCTest
@testable import PusherApp
class PusherServiceTests: XCTestCase {
    let pusherService = PusherMessageService()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanOnlySubscribeOneCallback() throws {
        var caughtResults1 = [Result<Message, ApplicationError>]()
        var caughtResults2 = [Result<Message, ApplicationError>]()
        let expectation = XCTestExpectation(description: "Expectation")
        pusherService.subscribe { result in
            caughtResults1.append(result)
            print(result)
            XCTFail("this callback should not be executed.")
        }
       
        

        pusherService.subscribe { result in
            print(result)
            caughtResults2.append(result)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {[weak self] in
            self?.pusherService.unsubscribe()
            print("results")

            print(caughtResults2)
            print(caughtResults1)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5.01)

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
