//
//  URLSessionStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class URLSessionStubTests: XCTestCase {

    func testStubsRequests() {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)
        let expectedResponse = HTTPURLResponse()

        let urlSessionStub = URLSessionStub(configuration: .ephemeral,
                                            stubSource:EphemeralStubSource())
        var request = URLRequest(url: URL(string:"127.0.0.1")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B":"BBB"]

        urlSessionStub.stub(request, data: "abc".data(using: .utf8), response: expectedResponse, error: TestError.expected)

        let dataTask = urlSessionStub.stubSource?.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse, response)
            XCTAssertEqual(TestError.expected.localizedDescription, error?.localizedDescription)

            exp.fulfill()
        }
        dataTask?.resume()

        wait(for: [exp], timeout: 0.1)
    }

    func testDefaultRecordMode() {
        let urlSessionStub = URLSessionStub(configuration: .ephemeral)
        XCTAssertEqual(urlSessionStub.recordMode, .playback)
    }

    func testRecordsInRecordMode() {
        let exp = expectation(description: "Wait for data task completion")
        let urlSessionStubStub = URLSessionStub(configuration: .ephemeral)
        let url = URL(string: "127.0.0.1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B":"BBB"]

        urlSessionStubStub.stub(request, data: "abc".data(using: .utf8))

        let urlSessionStub = URLSessionStub(configuration: .ephemeral,
                                            stubSource: EphemeralStubSource(),
                                            endToEndURLSession: urlSessionStubStub)
        urlSessionStub.recordMode = .recording

        let dataTask = urlSessionStub.dataTask(with: request) { (_, _, _) in
            exp.fulfill()
        }
        dataTask.resume()

        wait(for: [exp], timeout: 0.1)

        let stubDidStoreExpectation = expectation(description: "StubSource finds a record for the request")
        let stubSourceDataTask = urlSessionStub.stubSource?.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(data, "abc".data(using: .utf8))
            XCTAssertNil(error)
            stubDidStoreExpectation.fulfill()
        }
        stubSourceDataTask?.resume()

        wait(for: [stubDidStoreExpectation], timeout: 0.1)
    }

    static var allTests = [
        ("testStubsRequests", testStubsRequests),
        ("testDefaultRecordMode", testDefaultRecordMode),
        ("testRecordsInRecordMode", testRecordsInRecordMode),
    ]
}
