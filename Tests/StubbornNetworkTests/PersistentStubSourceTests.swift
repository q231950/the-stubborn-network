//
//  StubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.08.19.
//

import XCTest
@testable import StubbornNetwork

class StubSourceTests: XCTestCase {

    func testPath() {
        let url = URL(string: "127.0.0.1")!

        let stubSource = PersistentStubSource(name: "a name", path: url)
        XCTAssertEqual(stubSource.path.absoluteString, "127.0.0.1/a_name.json")
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
        let url = URL(string: "127.0.0.1")!

        var stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub)

        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertEqual(stub, loadedStub)
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
