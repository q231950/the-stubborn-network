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

    func test_persistentStubSource_canBeInitialized_givenAPathAndName() {
        let stubSource = PersistentStubSource(name: "a name", path: stubSourceUrl)
        XCTAssertEqual(stubSource.path.absoluteString, "\(stubSourceUrl.absoluteString)/a_name.json")
    }

    func test_persistentStubSource_canBeInitialized_givenAProcessInfo() throws {
        let processInfo = ProcessInfoStub(stubName: "Stub", stubPath: TestHelper.testingStubSourcePath())
        let location = try XCTUnwrap(StubSourceLocation(processInfo: processInfo))
        XCTAssertNotNil(PersistentStubSource(with: location))
    }

    func test_persistentStubSource_loadsStub_forRequestWithBodyData() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://api.abc.com")
        var request = URLRequest(url: url!)
        request.httpBody = "abc".data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]
        let loadedStub = stubSource.stub(forRequest: request, options: .strict)

        XCTAssertNotNil(loadedStub)
    }

    func test_persistentStubSource_loadsStub_forRequestWithoutBodyData() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://api.abc.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["D": "DDD"]
        let loadedStub = stubSource.stub(forRequest: request, options: .strict)

        XCTAssertNotNil(loadedStub)
    }

    func test_persistentStubSource_storesStub() {
        let url = URL(string: "127.0.0.1/abc")!

        let stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub, options: .strict)

        let loadedStub = stubSource.stub(forRequest: request, options: .strict)

        XCTAssertEqual(stub, loadedStub)
    }

    func test_persistentStubSource_storesNoDuplicateRequests() throws {
        let url = URL(string: "127.0.0.1/abc")!

        let stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request, data: nil, response: nil, error: nil)
        stubSource.store(stub, options: .strict)
        stubSource.store(stub, options: .strict)

        XCTAssertEqual(stubSource.stubs.count, 1)
    }

    func test_persistentStubSource_clearsStubs() {
        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)
        stubSource.clear()
        stubSource.setupStubs(from: prerecordedStubMockData)
        XCTAssertEqual(stubSource.stubs.count, 3)

        stubSource.clear()

        XCTAssertEqual(stubSource.stubs.count, 0)
    }

    func test_persistentStubSource_savesToDisk() {
        let stubSource = PersistentStubSource(name: "the stubborn network testing", path: stubSourceUrl)
        stubSource.setupStubs(from: prerecordedStubMockData)
        stubSource.save(stubSource.stubs)

        let secondStubSource = PersistentStubSource(name: "the stubborn network testing", path: stubSourceUrl)
        XCTAssertEqual(secondStubSource.stubs.count, 3)
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
        ("test_persistentStubSource_canBeInitialized_givenAPathAndName",
        test_persistentStubSource_canBeInitialized_givenAPathAndName),
        ("test_persistentStubSource_canBeInitialized_givenAProcessInfo",
        test_persistentStubSource_canBeInitialized_givenAProcessInfo),
        ("test_persistentStubSource_loadsStub_forRequestWithBodyData",
         test_persistentStubSource_loadsStub_forRequestWithBodyData),
        ("test_persistentStubSource_loadsStub_forRequestWithoutBodyData",
         test_persistentStubSource_loadsStub_forRequestWithoutBodyData),
        ("test_persistentStubSource_storesStub",
        test_persistentStubSource_storesStub),
        ("test_persistentStubSource_storesNoDuplicateRequests",
        test_persistentStubSource_storesNoDuplicateRequests),
        ("test_persistentStubSource_clearsStubs",
        test_persistentStubSource_clearsStubs)
    ]
}
