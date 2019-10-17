//
//  URLRequestMatcherTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.10.19.
//

import XCTest
@testable import StubbornNetwork

class URLRequestMatcherTests: XCTestCase {
    func testMatchesRequestHeadersCaseSensitively() throws {
        var requestWithCapitalHeader = URLRequest(url: try XCTUnwrap(URL(string: "127.0.0.1")))
        requestWithCapitalHeader.setValue("alphabet", forHTTPHeaderField: "ABC")

        var requestWithLowercaseHeader = URLRequest(url: try XCTUnwrap(URL(string: "127.0.0.1")))
        requestWithLowercaseHeader.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestWithCapitalHeader.matches(request: requestWithLowercaseHeader))
    }
}
