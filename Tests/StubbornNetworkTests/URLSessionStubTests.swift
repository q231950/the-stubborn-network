//
//  URLSessionStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class TestingStubSource: StubSourceProtocol {
    var stored: RequestStub?

    func store(_ stub: RequestStub) {
        stored = stub
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        return URLSessionDataTask()
    }
}

class URLSessionStubTests: XCTestCase {

    var request = URLRequest(url: URL(string: "127.0.0.1")!)
    let urlSessionStub = URLSessionStub(configuration: .ephemeral)

    func testStubsRequests() {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)
        let expectedResponse = HTTPURLResponse()

        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        urlSessionStub.stub(request,
                            data: "abc".data(using: .utf8),
                            response: expectedResponse,
                            error: TestError.expected)

        let dataTask = urlSessionStub.stubSource?.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse, response)
            XCTAssertEqual(TestError.expected.localizedDescription, error?.localizedDescription)

            exp.fulfill()
        }
        dataTask?.resume()

        wait(for: [exp], timeout: 0.001)
    }

    func testDefaultRecordMode() {
        XCTAssertEqual(urlSessionStub.recordMode, .playback)
    }

    func testRecordsInRecordMode() {
        let exp = expectation(description: "Wait for data task completion")
        let urlSessionStubStub = URLSessionStub(configuration: .ephemeral)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        urlSessionStubStub.stub(request, data: "abc".data(using: .utf8))

        let urlSessionStub = URLSessionStub(configuration: .ephemeral,
                                            endToEndURLSession: urlSessionStubStub)
        urlSessionStub.recordMode = .recording

        let dataTask = urlSessionStub.dataTask(with: request) { (_, _, _) in
            exp.fulfill()
        }
        dataTask.resume()

        wait(for: [exp], timeout: 0.001)

        let stubDidStoreExpectation = expectation(description: "StubSource finds a record for the request")
        let stubSourceDataTask = urlSessionStub.stubSource?.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(data, "abc".data(using: .utf8))
            XCTAssertNil(response)
            XCTAssertNil(error)
            stubDidStoreExpectation.fulfill()
        }
        stubSourceDataTask?.resume()

        wait(for: [stubDidStoreExpectation], timeout: 0.001)
    }

    func testStoresProcessedRequestBody() {
        let stubSource = TestingStubSource()
        let urlSessionStub = URLSessionStub(stubSource: stubSource)
        urlSessionStub.bodyDataProcessor = TestingBodyDataProcessor()

        request.httpBody = "11x11".data(using: .utf8)
        urlSessionStub.stub(request,
                            data: nil,
                            response: nil,
                            error: nil)

        XCTAssertEqual(stubSource.stored?.request.httpBody, "1111".data(using: .utf8))
    }

    func testStoresProcessedResponseBody() {
        let exp = expectation(description: "Wait for data task completion")
        urlSessionStub.bodyDataProcessor = TestingBodyDataProcessor()

        urlSessionStub.stub(request,
                            data: "11y11".data(using: .utf8),
                            response: nil,
                            error: nil)

        let dataTask = urlSessionStub.stubSource?.dataTask(with: request) { (data, _, _) in
            XCTAssertEqual("1111".data(using: .utf8), data)

            exp.fulfill()
        }
        dataTask?.resume()

        wait(for: [exp], timeout: 0.001)
    }

    static var allTests = [
        ("testStubsRequests", testStubsRequests),
        ("testDefaultRecordMode", testDefaultRecordMode),
        ("testRecordsInRecordMode", testRecordsInRecordMode),
        ("testStoresProcessedRequestBody", testStoresProcessedRequestBody),
        ("testStoresProcessedResponseBody", testStoresProcessedResponseBody),
    ]
}
