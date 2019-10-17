//
//  URLRequestMatcherTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.10.19.
//

import XCTest
@testable import StubbornNetwork

class URLRequestMatcherTests: XCTestCase {
    func testMatchesRequestHeadersCaseSensitively() {
        var requestWithCapitalHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithCapitalHeader.setValue("alphabet", forHTTPHeaderField: "ABC")

        var requestWithLowercaseHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithLowercaseHeader.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestWithCapitalHeader.matches(request: requestWithLowercaseHeader))
    }

    func testHeaderDuplicateMismatches() {
        var requestWithDuplicatedHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithDuplicatedHeader.setValue("alphabet", forHTTPHeaderField: "ABC")
        requestWithDuplicatedHeader.addValue("алфавит", forHTTPHeaderField: "ABC")

        var requestWithSingleHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithSingleHeader.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestWithDuplicatedHeader.matches(request: requestWithSingleHeader))
    }

    func testHeaderDuplicateMatches() {
        var requestWithDuplicatedHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithDuplicatedHeader.addValue("alphabet", forHTTPHeaderField: "ABC")
        requestWithDuplicatedHeader.addValue("алфавит", forHTTPHeaderField: "ABC")

        var requestWithDuplicatedLowercaseHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithDuplicatedLowercaseHeader.addValue("alphabet", forHTTPHeaderField: "abc")
        requestWithDuplicatedLowercaseHeader.addValue("алфавит", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestWithDuplicatedHeader.matches(request: requestWithDuplicatedLowercaseHeader))
    }

    func testHeaderOrderMismatches() {
        var requestWithDuplicatedHeader = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithDuplicatedHeader.addValue("alphabet", forHTTPHeaderField: "abc")
        requestWithDuplicatedHeader.addValue("алфавит", forHTTPHeaderField: "abc")

        var requestWithDuplicatedHeaderOtherOrder = URLRequest(url: URL(string: "127.0.0.1")!)
        requestWithDuplicatedHeaderOtherOrder.addValue("алфавит", forHTTPHeaderField: "abc")
        requestWithDuplicatedHeaderOtherOrder.addValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestWithDuplicatedHeader.matches(request: requestWithDuplicatedHeaderOtherOrder))
    }
}
