//
//  RequestStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 07.08.19.
//

import XCTest
@testable import StubbornNetwork

final class RequestStubTests: XCTestCase {

    func testProperlyEncodesRequests() throws {
        var request = URLRequest(url: URL(string: "123.4.5.6")!)
        request.httpMethod = "POST"
        let requestStub = RequestStub(request: request)

        let encoder = JSONEncoder()
        let result = try encoder.encode(requestStub)
        let json = String(data:result, encoding: .utf8)
        XCTAssertEqual(json, """
        {\"request\":{\"url\":\"123.4.5.6\",\"headerFields\":[],\"method\":\"POST\"},\"data\":null,\"response\":{}}
        """)
    }

    func testDecodesData() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.data, "abc".data(using: .utf8)!)
    }

    func testDecodesHTTPMethod() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.request.httpMethod, "POST")
    }

    var jsonMockData: Data {
        get {
            return """
            {
                "request": {
                    "url": "https://api.abc.com",
                    "headerFields": [
                        "A[:::]AAA",
                        "Content-Type[:::]text/xml; charset=utf-8",
                        "Accept-Language[:::]en-us",
                        "Accept[:::]*/*",
                        "Accept-Encoding[:::]br, gzip, deflate"
                    ],
                    "method": "POST"
                },
                "data": "YWJj",
                "response": {}
            }
            """.data(using: .utf8)!
        }
    }
    
    static var allTests = [
        ("properlyEncodesStubbedRequest", testProperlyEncodesRequests),
        ("testDecodesData", testDecodesData),
        ("testDecodesHTTPMethod", testDecodesHTTPMethod),
    ]
}
