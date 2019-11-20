//
//  StubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.08.19.
//

import XCTest
@testable import StubbornNetwork

class StubSourceTests: XCTestCase {

    var stubSourceUrl = TestHelper.testingStubSourceUrl()

    func testPath() {
        let stubSource = PersistentStubSource(name: "a name", path: stubSourceUrl)
        XCTAssertEqual(stubSource.path.absoluteString, "\(stubSourceUrl.path)/a_name.json")
    }

    func testLoadsStubForRequest() {
        var stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://api.abc.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]
        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertNotNil(loadedStub)
    }

    func testStoresStubResponse() {
        let url = URL(string: "127.0.0.1/abc")!

        var stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub)

        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertEqual(stub, loadedStub)
    }

    func testDataTaskStub() {
        let asyncExpectation = expectation(description: "Wait for async completion")

        let url = URL(string: "\(stubSourceUrl.path)/123")!

        var stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: prerecordedStubMockData, response: URLResponse(), error: nil)
        stubSource.store(stub)

        let task = stubSource.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(self.prerecordedStubMockData, data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            asyncExpectation.fulfill()
        }
        task.resume()
        wait(for: [asyncExpectation], timeout: 0.001)
    }

    var prerecordedStubMockData: Data {
        String("""
            [
                {
                    "request": {
                        "url": "https://api.abc.com",
                        "headerFields": [
                            "A[:::]AAA"
                        ],
                        "method": "GET"
                    },
                    "data": "YWJj",
                    "response": {}
                },
                {
                    "request": {
                        "url": "https://api.abc.com",
                        "headerFields": [
                            "B[:::]BBB"
                        ],
                        "method": "POST"
                    },
                    "data": "YWJj",
                    "response": {
                        "statusCode": 200,
                        "headerFields": [
                            "C[:::]CCC"
                        ]
                    }
                },
                {
                    "request": {
                        "url": "https://api.abc.com",
                        "headerFields": [
                            "D[:::]DDD"
                        ],
                        "method": "POST"
                    },
                    "data": "YWJj",
                    "response": {
                        "statusCode": 200,
                        "headerFields": [
                            "E[:::]EEE"
                        ]
                    }
                }
            ]

            """).data(using: .utf8)!
    }

    static var allTests = [
        ("testLoadsStubForRequest", testLoadsStubForRequest),
        ("testStoresStubResponse", testStoresStubResponse),
    ]
}
