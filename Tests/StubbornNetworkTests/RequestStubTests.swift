//
//  RequestStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 07.08.19.
//

import XCTest
@testable import StubbornNetwork

final class RequestStubTests: XCTestCase {

    func testProperlyEncodesURL() throws {
        let request = URLRequest(url: URL(string: "123.4.5.6")!)
        let requestStub = RequestStub(request: request)

        let encoder = JSONEncoder()
        let result = try encoder.encode(requestStub)
        let json = String(data:result, encoding: .utf8)
        XCTAssertEqual(json, """
        {\"request\":{\"url\":\"123.4.5.6\",\"headerFields\":null,\"method\":\"GET\"},\"data\":null,\"response\":{}}
        """)
    }

    func testDecodesData() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.data, "abc".data(using: .utf8)!)
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
        ("properlyEncodesStubbedRequest", testProperlyEncodesURL),
    ]
}
