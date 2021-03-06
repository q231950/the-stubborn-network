//
//  PrivacyHandlerTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.10.19.
//

import XCTest
@testable import StubbornNetwork

class BodyDataProcessorTests: XCTestCase {

    let bodyDataProcessor = BodyDataProcessorStub()
    var request: URLRequest!
    var session: URLSession!

    override func setUp() {
        super.setUp()

        request = URLRequest(url: URL(string: "https://elbedev.com")!)
        StubbornNetwork.standard.bodyDataProcessor = bodyDataProcessor

        let configuration: URLSessionConfiguration = .ephemeral

        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)

        session = URLSession(configuration: configuration)

        StubbornNetwork.standard.ephemeralStubSource = EphemeralStubSource()
    }

    func testPreparesRequestBodyBeforeStorage() throws {
        // given
        let exp = expectation(description: "Wait for session")
        let data = "123".data(using: .utf8)
        request.httpBody = data
        let requestStub = RequestStub(request: request, response: nil, responseData: nil, error: nil)

        // when
        StubbornNetwork.standard.ephemeralStubSource?.store(requestStub, options: .strict)

        // then
        session.dataTask(with: try XCTUnwrap(URL(string: "127.0.0.1"))) { (data, _, _) in
            XCTAssertEqual(self.bodyDataProcessor.collector.dataForStoringRequestBody, data)
            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 0.1)

    }

    func testPreparesResponseBodyBeforeStorage() throws {
        // given
        let exp = expectation(description: "Wait for session")
        let data = "123".data(using: .utf8)
        let requestStub = RequestStub(request: request, response: nil, responseData: data, error: nil)

        // when
        StubbornNetwork.standard.ephemeralStubSource?.store(requestStub, options: .strict)

        // then
        session.dataTask(with: try XCTUnwrap(URL(string: "127.0.0.1"))) { (data, _, _) in
            XCTAssertEqual(self.bodyDataProcessor.collector.dataForStoringResponseBody, data)
            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 0.1)
    }

    func testPreparesResponseBodyBeforeDelivery() throws {
        // given
        let exp = expectation(description: "Wait for session")
        let data = "123".data(using: .utf8)
        let requestStub = RequestStub(request: request, responseData: data)
        StubbornNetwork.standard.ephemeralStubSource?.store(requestStub, options: .strict)

        // when
        session.dataTask(with: request) { (data, _, _) in

            // then
            let actualResponseBody = String(data: data!, encoding:
                .utf8)
            XCTAssertEqual(actualResponseBody, "🐻🐞 dataForDeliveringResponseBody 🐻🐞")
            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 0.1)
    }

    static var allTests = [
        ("testPreparesRequestBodyBeforeStorage", testPreparesRequestBodyBeforeStorage),
        ("testPreparesResponseBodyBeforeStorage", testPreparesResponseBodyBeforeStorage),
        ("testPreparesResponseBodyBeforeDelivery", testPreparesResponseBodyBeforeDelivery),
    ]
}
