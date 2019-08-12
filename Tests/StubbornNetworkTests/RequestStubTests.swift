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
        let request = URLRequest(url: URL(string: "127.0.0.1")!)
        let requestStub = RequestStub(request: request)

        let encoder = JSONEncoder()
        let result = try encoder.encode(requestStub)
        let json = String(data:result, encoding: .utf8)
    }

    func testDecodesData() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.data, "abc".data(using: .utf8))
    }

    var jsonMockData: Data {
        get {
            return String("""
        {"request":{"url":"https://zones.buecherhallen.de/app_webuser/WebUserSvc.asmx","headerFields":["SOAPAction:http://bibliomondo.com/websevices/webuser/CheckBorrower","Accept-Encoding:br, gzip, deflate","Accept:*/*","Content-Type:text/xml; charset=utf-8","Accept-Language:en-us"]},"data":"YWJj","response":{"statusCode":200,"headerFields":["X-AspNet-Version:2.0.50727","Date:Thu, 08 Aug 2019 04:44:32 GMT","Server:Microsoft-IIS/8.0","X-Powered-By:ASP.NET","Content-Encoding:gzip","Content-Type:text/xml; charset=utf-8","Cache-Control:private, max-age=0","Content-Length:615","Vary:Accept-Encoding"]}}
        """).data(using: .utf8)!
        }
    }

    static var allTests = [
        ("properlyEncodesStubbedRequest", testProperlyEncodesURL),
    ]
}
