//
//  EphemeralStubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class EphemeralStubSourceTests: XCTestCase {

    func test_ephemeralStubSource_storesStubs() throws {
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let expectedResponse: URLResponse? = URLResponse(url: url,
                                                         mimeType: "text/html",
                                                         expectedContentLength: 3,
                                                         textEncodingName: "utf-8")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]
        request.httpBody = "abc".data(using: .utf8)

        let stub = RequestStub(request: request,
                               response: expectedResponse,
                               responseData: nil,
                               error: nil)

        let stubSource = EphemeralStubSource()
        stubSource.store(stub, options: .strict)

        XCTAssertTrue(stubSource.hasStub(request, options: .strict))
        XCTAssertEqual(stubSource.stubs.count, 1)
    }

    func test_ephemeralStubSource_storesNoDuplicateRequests() throws {
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let expectedResponse: URLResponse? = URLResponse(url: url,
                                                         mimeType: "text/html",
                                                         expectedContentLength: 0,
                                                         textEncodingName: "utf-8")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request,
                               response: expectedResponse,
                               responseData: nil,
                               error: nil)

        let stubSource = EphemeralStubSource()
        stubSource.store(stub, options: .strict)
        stubSource.store(stub, options: .strict)

        XCTAssertEqual(stubSource.stubs.count, 1)
    }

    static var allTests = [
        ("test_ephemeralStubSource_storesStubs",
         test_ephemeralStubSource_storesStubs),
        ("test_ephemeralStubSource_storesNoDuplicateRequests",
         test_ephemeralStubSource_storesNoDuplicateRequests)
    ]
}
