//
//  EphemeralStubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class EphemeralStubSourceTests: XCTestCase {

    var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration: URLSessionConfiguration = .ephemeral

        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)

        session = URLSession(configuration: configuration)
    }

    func testInitializer() {
        let stubSource = EphemeralStubSource()

        XCTAssertNotNil(stubSource)
    }

    func testStoresStub() throws {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let expectedResponse: URLResponse? = URLResponse(url: url, mimeType: "text/html", expectedContentLength: 3, textEncodingName: "utf-8")

        let stubSource = EphemeralStubSource()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request,
                               data: "abc".data(using: .utf8),
                               response: expectedResponse,
                               error: nil)
        stubSource.store(stub)

        StubbornNetwork.standard.ephemeralStubSource = stubSource

        session.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse?.url, response?.url)
            XCTAssertNil(error)

            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 1)
    }

    static var allTests = [
        ("testInitializer", testInitializer),
        ("testStoresStub", testStoresStub)
    ]
}
