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
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration: URLSessionConfiguration = .ephemeral

        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)
        StubbornNetwork.standard.removeBodyDataProcessor()

        session = URLSession(configuration: configuration)
    }

    func testPath() {
        let stubSource = PersistentStubSource(name: "a name", path: stubSourceUrl)
        XCTAssertEqual(stubSource.path.absoluteString, "\(stubSourceUrl.path)/a_name.json")
    }

    func test_persistentStubSource_findsLocation_inProcessInfo() throws {
        let processInfo = ProcessInfoStub(stubName: "Stub", stubPath: TestHelper.testingStubSourcePath())
        let location = StubSourceLocation(processInfo: processInfo)
        XCTAssertNotNil(PersistentStubSource(with: try XCTUnwrap(location)))
    }

    func test_persistentStubSource_loadsStub_forRequestWithBodyData() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://api.abc.com")
        var request = URLRequest(url: url!)
        request.httpBody = "abc".data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]
        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertNotNil(loadedStub)
    }

    func test_persistentStubSource_loadsStub_forRequestWithoutBodyData() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://api.abc.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["D": "DDD"]
        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertNotNil(loadedStub)
    }

    func testStoresStubResponse() {
        let url = URL(string: "127.0.0.1/abc")!

        let stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub)

        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertEqual(stub, loadedStub)
    }

    func test_persistentStubSource_storesNoDuplicateRequests() throws {
        let url = URL(string: "127.0.0.1/abc")!

        let stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub)
        stubSource.store(stub)

        XCTAssertEqual(stubSource.stubs.count, 1)
    }

    func test_persistentStubSource_clearsStubs() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)
        XCTAssertEqual(stubSource.stubs.count, 3)

        stubSource.clear()

        XCTAssertEqual(stubSource.stubs.count, 0)
    }

    var prerecordedStubMockData: Data {
        String("""
            [
                {
                    "request": {
                        "url": "https://api.abc.com",
                        "requestData": null,
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
                        "requestData": "YWJj",
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
                        "requestData": null,
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
        ("test_persistentStubSource_findsLocation_inProcessInfo",
        test_persistentStubSource_findsLocation_inProcessInfo),
        ("test_persistentStubSource_loadsStub_forRequestWithBodyData",
         test_persistentStubSource_loadsStub_forRequestWithBodyData),
        ("test_persistentStubSource_loadsStub_forRequestWithoutBodyData",
         test_persistentStubSource_loadsStub_forRequestWithoutBodyData),
        ("testStoresStubResponse", testStoresStubResponse),
    ]
}
