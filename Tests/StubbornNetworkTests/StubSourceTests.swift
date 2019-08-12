//
//  StubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.08.19.
//

import XCTest
@testable import StubbornNetwork

class StubSourceTests: XCTestCase {
    func testLoadsStubForRequest() {
        var stubSource = StubSource(url: URL(string: "127.0.0.1")!)
        stubSource.setupStubs(from: prerecordedStubMockData)

        let url = URL(string: "https://zones.buecherhallen.de/app_webuser/WebUserSvc.asmx")
        var request = URLRequest(url: url!)
        request.allHTTPHeaderFields = ["Accept-Language": "en-us", "Accept": "*/*", "Accept-Encoding": "br, gzip, deflate", "SOAPAction": "//bibliomondo.com/websevices/webuser/CheckBorrower", "Content-Type": "text/xml; charset=utf-8"]
        let loadedStub = stubSource.stub(forRequest: request)

        XCTAssertEqual(loadedStub?.data, "abc".data(using: .utf8))
    }

    var prerecordedStubMockData: Data {
        get {
            return String("""
            [{"request":{"url":"https://zones.buecherhallen.de/app_webuser/WebUserSvc.asmx","headerFields":["SOAPAction:http://bibliomondo.com/websevices/webuser/CheckBorrower","Accept-Encoding:br, gzip, deflate","Accept:*/*","Content-Type:text/xml; charset=utf-8","Accept-Language:en-us"]},"data":"YWJj","response":{"statusCode":200,"headerFields":["X-AspNet-Version[:::]2.0.50727","Date[:::]Thu, 08 Aug 2019 04:44:32 GMT","Server[:::]Microsoft-IIS/8.0","X-Powered-By[:::]ASP.NET","Content-Encoding[:::]gzip","Content-Type[:::]text/xml; charset=utf-8","Cache-Control[:::]private, max-age=0","Content-Length[:::]615","Vary[:::]Accept-Encoding"]}},{"request":{"url":"https://zones.buecherhallen.de/app_webuser/WebUserSvc.asmx","headerFields":["Accept[:::]*/*","Accept-Language[:::]en-us","Content-Type[:::]text/xml; charset=utf-8","Accept-Encoding[:::]br, gzip, deflate","SOAPAction[:::]http://bibliomondo.com/websevices/webuser/GetBorrowerLoans"]},"data":"MTIz","response":{"statusCode":200,"headerFields":["X-AspNet-Version[:::]2.0.50727","Date[:::]Thu, 08 Aug 2019 04:44:32 GMT","Server[:::]Microsoft-IIS/8.0","X-Powered-By[:::]ASP.NET","Content-Encoding[:::]gzip","Content-Type[:::]text/xml; charset=utf-8","Cache-Control[:::]private, max-age=0","Content-Length[:::]377","Vary[:::]Accept-Encoding"]}}]
            """).data(using: .utf8)!
        }
    }
}
