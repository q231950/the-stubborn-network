//
//  StubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.08.19.
//

import XCTest
@testable import StubbornNetwork

class StubSourceTests: XCTestCase {

    var stubSourceUrl: URL = {
        TestHelper.testingStubSourceUrl()
    }()

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

    func test_persistentStubSource_loadsStub_forRequestWithBodyData() throws {
        let path = try XCTUnwrap(URL(string: stubSourceUrl.absoluteString))
        let stubSource = PersistentStubSource(name: "aaa", path: path)
        stubSource.setupStubs(from: prerecordedStubMockData)
        stubSource.save(stubSource.stubs)

        let url = try XCTUnwrap(URL(string: "https://api.elbedev.com"))
        var request = URLRequest(url: url)
        request.httpBody = "abc".data(using: .utf8)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stubSource2 = PersistentStubSource(name: "aaa", path: path)
        let loadedStub = stubSource2.stub(forRequest: request, options: .strict)

        XCTAssertNotNil(loadedStub)
    }

    func test_persistentStubSource_loadsStub_forRequestWithoutBodyData() throws {
        let path = try XCTUnwrap(URL(string: stubSourceUrl.absoluteString))
        let stubSource = PersistentStubSource(name: "aaa", path: path)
        stubSource.setupStubs(from: prerecordedStubMockData)
        stubSource.save(stubSource.stubs)

        let url = URL(string: "https://api.elbedev.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["D": "DDD"]

        let stubSource2 = PersistentStubSource(name: "aaa", path: path)
        let loadedStub = stubSource2.stub(forRequest: request, options: .strict)

        XCTAssertNotNil(loadedStub)
    }

    func test_persistentStubSource_storesStub() throws {
        let path = try XCTUnwrap(URL(string: TestHelper.testingStubSourcePath()))

        let filename = UUID().uuidString
        let stubSource = PersistentStubSource(name: filename, path: path)

        let url = try XCTUnwrap(URL(string: "127.0.0.1/abc"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let response = HTTPURLResponse(url: url,
                                       mimeType: "text/html",
                                       expectedContentLength: 3,
                                       textEncodingName: "utf-8")

        let stub = RequestStub(request: request, response: response)
        stubSource.store(stub, options: .strict)

        let secondStubSource = PersistentStubSource(name: filename, path: path)

        let loadedStub = secondStubSource.stub(forRequest: request, options: .strict)

        XCTAssertEqual(loadedStub?.request, request)
        XCTAssertEqual(loadedStub?.response?.url, response.url)
    }

    func test_persistentStubSource_storesDuplicateRequests() throws {
        let url = URL(string: "127.0.0.1/abc")!

        let stubSource = PersistentStubSource(path: url)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request)
        stubSource.store(stub, options: .strict)
        stubSource.store(stub, options: .strict)

        XCTAssertEqual(stubSource.stubs.count, 2)
    }

    func test_persistentStubSource_clearsStubs() throws {
        let path = try XCTUnwrap(URL(string: TestHelper.testingStubSourcePath()))
        let stubSource = PersistentStubSource(path: path)
        stubSource.clear()
        stubSource.setupStubs(from: prerecordedStubMockData)
        XCTAssertEqual(stubSource.stubs.count, 3)

        stubSource.clear()

        XCTAssertEqual(stubSource.stubs.count, 0)
    }

    func test_persistentStubSource_savesToDisk() throws {
        let path = try XCTUnwrap(URL(string: TestHelper.testingStubSourcePath()))

        FileManager.default.createFile(atPath: path.appendingPathComponent("aaa.json").absoluteString, contents: nil, attributes: nil)

        let stubSource = PersistentStubSource(name: "aaa", path: path)
        stubSource.setupStubs(from: prerecordedStubMockData)

        stubSource.save(stubSource.stubs)

        let secondStubSource = PersistentStubSource(path: path.appendingPathComponent("aaa.json"))
        XCTAssertEqual(secondStubSource.stubs.count, 3)
    }

    var prerecordedStubMockData: Data {
        String("""
            [
                {
                    "request": {
                        "url": "https://api.elbedev.com",
                        "requestData": null,
                        "headerFields": [
                            "A[:::]AAA"
                        ],
                        "method": "GET"
                    },
                    "response": {
                        "responseData": "YWJj",
                        "url": "https://api.q231950.com",
                        "statusCode": 200,
                        "headerFields": []
                    }
                },
                {
                    "request": {
                        "url": "https://api.elbedev.com",
                        "requestData": "YWJj",
                        "headerFields": [
                            "B[:::]BBB"
                        ],
                        "method": "POST"
                    },
                    "response": {
                        "statusCode": 200,
                        "headerFields": [
                            "C[:::]CCC"
                        ],
                        "responseData": "YWJj",
                        "url": "https://api.q231950.com",
                        "statusCode": 200
                    }
                },
                {
                    "request": {
                        "url": "https://api.elbedev.com",
                        "requestData": null,
                        "headerFields": [
                            "D[:::]DDD"
                        ],
                        "method": "POST"
                    },
                    "response": {
                        "statusCode": 200,
                        "headerFields": [
                            "E[:::]EEE"
                        ],
                        "responseData": "YWJj",
                        "url": "https://api.q231950.com",
                        "statusCode": 200
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
        ("test_persistentStubSource_storesDuplicateRequests",
        test_persistentStubSource_storesDuplicateRequests),
        ("test_persistentStubSource_clearsStubs",
        test_persistentStubSource_clearsStubs)
    ]
}
