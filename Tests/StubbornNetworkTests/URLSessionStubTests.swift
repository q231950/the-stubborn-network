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

        let stubSource = EphemeralStubSource()
        let urlSessionStub = URLSessionStub(configuration: .ephemeral, stubSource:stubSource)
        var request = URLRequest(url: URL(string:"127.0.0.1")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B":"BBB"]

        urlSessionStub.stub(request, data: "abc".data(using: .utf8), response: expectedResponse, error: TestError.expected)

        let dataTask = stubSource.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse, response)
            XCTAssertEqual(TestError.expected.localizedDescription, error?.localizedDescription)

            exp.fulfill()
        }
        dataTask.resume()

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

        let stubSource = EphemeralStubSource()

        let urlSessionStub = URLSessionStub(configuration: .ephemeral, stubSource:stubSource, endToEndURLSession: urlSessionStubStub)
        urlSessionStub.recordMode = .recording

        let dataTask = urlSessionStub.dataTask(with: request) { (data, response, error) in
            exp.fulfill()
        }
        dataTask.resume()

        wait(for: [exp], timeout: 0.1)

        let stubDidStoreExpectation = expectation(description: "StubSource finds a record for the request")
        let stubSourceDataTask = stubSource.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(data, "abc".data(using: .utf8))
            stubDidStoreExpectation.fulfill()
        }
        stubSourceDataTask.resume()

        wait(for: [stubDidStoreExpectation], timeout: 0.1)
    }

    /// TODO: the `setupStubSource` method does not make sense for the `EphemeralStubSource`. Think about it.
    func testSetupStubSource() {
        let urlSessionStub = URLSessionStub(configuration: .ephemeral)
        let url = URL(string:"127.0.0.1")!

        urlSessionStub.setupStubSource(name: "a name", path: url)
    }

    static var allTests = [
        ("testStubsRequests", testStubsRequests),
        ("testDefaultRecordMode", testDefaultRecordMode),
        ("testSetupStubSource", testSetupStubSource),
    ]
}
