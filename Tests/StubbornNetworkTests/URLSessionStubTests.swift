//
//  URLSessionStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class TestingStubSource: EphemeralStubSource {

    // Keep track of what is being stored
    var stored = [RequestStub]()

    override func store(_ stub: RequestStub) {
        stored.append(stub)
        super.store(stub)
    }

    // Manipulate storage of the StubSource
    func injectStubIntoStorage(stub: RequestStub) {
        super.store(stub)
    }

}

class URLSessionStubTests: XCTestCase {

    var requestA: URLRequest = {
        var request = URLRequest(url: URL(string: "127.0.0.1")!)
        request.httpBody = nil
        return request
    }()

    var requestB: URLRequest = {
        var request = URLRequest(url: URL(string: "127.0.0.2")!)
        request.httpBody = nil
        return request
    }()

    let urlSessionStub = URLSessionStub(configuration: .ephemeral)

    func testStubsRequests() {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)
        let expectedResponse = HTTPURLResponse()

        requestA.httpMethod = "POST"
        requestA.allHTTPHeaderFields = ["B": "BBB"]

        urlSessionStub.stub(requestA,
                            data: "abc".data(using: .utf8),
                            response: expectedResponse,
                            error: TestError.expected)

        let dataTask = urlSessionStub.stubSource?.dataTask(with: requestA) { (data, response, error) in
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
        requestA.httpMethod = "POST"
        requestA.allHTTPHeaderFields = ["B": "BBB"]

        urlSessionStubStub.stub(requestA, data: "abc".data(using: .utf8))

        let urlSessionStub = URLSessionStub(configuration: .ephemeral,
                                            endToEndURLSession: urlSessionStubStub)
        urlSessionStub.recordMode = .record

        let dataTask = urlSessionStub.dataTask(with: requestA) { (_, _, _) in
            exp.fulfill()
        }
        dataTask.resume()

        wait(for: [exp], timeout: 0.001)

        let stubDidStoreExpectation = expectation(description: "StubSource finds a record for the request")
        let stubSourceDataTask = urlSessionStub.stubSource?.dataTask(with: requestA) { (data, response, error) in
            XCTAssertEqual(data, "abc".data(using: .utf8))
            XCTAssertNil(response)
            XCTAssertNil(error)
            stubDidStoreExpectation.fulfill()
        }
        stubSourceDataTask?.resume()

        wait(for: [stubDidStoreExpectation], timeout: 0.001)
    }

    func testRecordsOnlyNewInRecordNewMode() {
        let asyncExpectation = expectation(description: "Wait for data task completion")
        asyncExpectation.expectedFulfillmentCount = 2

        let stubSource = TestingStubSource()
        let urlSessionStubStub = URLSessionStub(configuration: .ephemeral)
        let urlSessionStub = URLSessionStub(stubSource: stubSource, endToEndURLSession: urlSessionStubStub)

        // when the stub source has stubbed request A
        stubSource.injectStubIntoStorage(stub: RequestStub(request: requestA))

        // and the record mode tells to only record new requests
        urlSessionStub.recordMode = .recordNew

        // when resuming the data task of the existing, stubbed request A
        urlSessionStub.dataTask(with: requestA) { (_, _, _) in
            asyncExpectation.fulfill()
        }.resume()

        // and a never recorded request B
        urlSessionStub.dataTask(with: requestB) { (_, _, _) in
            asyncExpectation.fulfill()
        }.resume()
        wait(for: [asyncExpectation], timeout: 0.001)

        // then only the new request B should have been stored freshly
        XCTAssertEqual(stubSource.stored.filter({ $0.request.matches(request: requestB) }).count, 1)
    }

    func testStoresProcessedRequestBody() {
        let stubSource = TestingStubSource()
        let urlSessionStub = URLSessionStub(stubSource: stubSource)
        urlSessionStub.bodyDataProcessor = TestingBodyDataProcessor()

        requestA.httpBody = "11x11".data(using: .utf8)
        urlSessionStub.stub(requestA,
                            data: nil,
                            response: nil,
                            error: nil)

        XCTAssertEqual(stubSource.stored.first?.request.httpBody, "1111".data(using: .utf8))
    }

    func testStoresProcessedResponseBody() {
        let exp = expectation(description: "Wait for data task completion")
        urlSessionStub.bodyDataProcessor = TestingBodyDataProcessor()

        urlSessionStub.stub(requestA,
                            data: "11y11".data(using: .utf8),
                            response: nil,
                            error: nil)

        let dataTask = urlSessionStub.stubSource?.dataTask(with: requestA) { (data, _, _) in
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
        ("testRecordsOnlyNewInRecordNewMode", testRecordsOnlyNewInRecordNewMode),
        ("testStoresProcessedRequestBody", testStoresProcessedRequestBody),
        ("testStoresProcessedResponseBody", testStoresProcessedResponseBody),
    ]
}
