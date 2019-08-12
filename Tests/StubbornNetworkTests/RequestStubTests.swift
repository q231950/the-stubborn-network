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
//        XCTAssertEqual(json, """
//        {\"request\":{\"url\":\"127.0.0.1\",\"headerFields\":null},\"data\":null,\"response\":{}}
//        """)

        let s = """
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48c29hcDpFbnZlbG9wZSB4bWxuczpzb2FwPSJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy9zb2FwL2VudmVsb3BlLyIgeG1sbnM6eHNpPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxL1hNTFNjaGVtYS1pbnN0YW5jZSIgeG1sbnM6eHNkPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxL1hNTFNjaGVtYSI+PHNvYXA6Qm9keT48Q2hlY2tCb3Jyb3dlclJlc3BvbnNlIHhtbG5zPSJodHRwOi8vYmlibGlvbW9uZG8uY29tL3dlYnNldmljZXMvd2VidXNlciI+PENoZWNrQm9ycm93ZXJSZXN1bHQ+PHVzZXJJZD41Nzc1NDQ4MTY8L3VzZXJJZD48cmVjb3JkPjxDaGVja0JvcnJvd2VyUmVzdWx0IHhtbG5zPSJodHRwOi8vYmlibGlvbW9uZG8uY29tL3dlYnNlcnZpY2VzL3dlYnVzZXIiPjxJZ25vcmVQaW4+MDwvSWdub3JlUGluPjxXYW50VXNlckRldGFpbHM+MDwvV2FudFVzZXJEZXRhaWxzPjxCcndyPkE1NyA3NTQgNDgxIDY8L0Jyd3I+PFBpbj4xMjg3PC9QaW4+PElzRW5jcnlwdGVkPjA8L0lzRW5jcnlwdGVkPjxUYXBObz4wPC9UYXBObz48TFJCPk9rPC9MUkI+PFZhbGlkYXRlZD4xPC9WYWxpZGF0ZWQ+PElzSW52YWxpZEJyd3JOdW0+MDwvSXNJbnZhbGlkQnJ3ck51bT48Q2F0ZWdvcnk+MjQ8L0NhdGVnb3J5PjxDYXRlZ29yeUNvZGU+TEU8L0NhdGVnb3J5Q29kZT48VXNlcklkPjg3MDA2MjwvVXNlcklkPjxGU0s+MTg8L0ZTSz48U3RhdHVzPkFjdGl2ZTwvU3RhdHVzPjxUcmFwVHlwZT48L1RyYXBUeXBlPjxzZXNzaW9uSWQgeG1sbnM9IiI+OTNEQTY4QjYxODFFQzk1QjFCMjZBOEUwRkJDQzJBNzA8L3Nlc3Npb25JZD48L0NoZWNrQm9ycm93ZXJSZXN1bHQ+PC9yZWNvcmQ+PC9DaGVja0JvcnJvd2VyUmVzdWx0PjwvQ2hlY2tCb3Jyb3dlclJlc3BvbnNlPjwvc29hcDpCb2R5Pjwvc29hcDpFbnZlbG9wZT4=
"""
        let d = s.data(using: .utf8)
//        let x = String(data: d!, encoding: .utf8)

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
