//
//  PrivacyHandlerTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.10.19.
//

import XCTest
@testable import StubbornNetwork

class BodyDataProcessorTests: XCTestCase {

    let bodyDataProcessor = TestingBodyDataProcessor()
    var stubbedSession: URLSessionStub!
    var request: URLRequest!

    override func setUp() {
        super.setUp()

        stubbedSession = URLSessionStub(configuration: .ephemeral, stubSource: EphemeralStubSource())
        request = URLRequest(url: URL(string: "127.0.0.1")!)
        stubbedSession.bodyDataProcessor = bodyDataProcessor
    }

    func testPreparesRequestBodyBeforeStorage() throws {
        let data = "123".data(using: .utf8)
        request.httpBody = data
        stubbedSession.stub(request, data: nil, response: nil, error: nil)
        XCTAssertEqual(bodyDataProcessor.collector.dataForStoringRequestBody, data)
    }

    func testPreparesResponseBodyBeforeStorage() throws {
        let data = "123".data(using: .utf8)
        stubbedSession.stub(request, data: data, response: nil, error: nil)
        XCTAssertEqual(bodyDataProcessor.collector.dataForStoringResponseBody, data)
    }

    func testPreparesResponseBodyBeforeDelivery() throws {
        let asyncExpectation = expectation(description: "Wait for async completion")
        let data = "123".data(using: .utf8)
        stubbedSession.stub(request, data: data, response: nil, error: nil)
        let task = stubbedSession?.dataTask(with: URL(string: "127.0.0.1")!, completionHandler: { (_, _, _) in
            XCTAssertEqual(self.bodyDataProcessor.collector.dataForDeliveringResponseBody, data)
            asyncExpectation.fulfill()
        })
        task?.resume()
        wait(for: [asyncExpectation], timeout: 0.001)
    }

    static var allTests = [
        ("testPreparesRequestBodyBeforeStorage", testPreparesRequestBodyBeforeStorage),
        ("testPreparesResponseBodyBeforeStorage", testPreparesResponseBodyBeforeStorage),
        ("testPreparesResponseBodyBeforeDelivery", testPreparesResponseBodyBeforeDelivery),
    ]
}
