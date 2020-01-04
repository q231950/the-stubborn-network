//
//  URLRequestMatcherTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.10.19.
//

import XCTest
@testable import StubbornNetwork

class URLRequestMatcherTests: XCTestCase {

    var requestA: URLRequest!
    var requestB: URLRequest!

    override func setUp() {
        super.setUp()

        do {
            requestA = try request()
            requestB = try request()
        } catch {
            XCTFail("Cannot set up test without requests A and B.")
        }
}

    func test_URLRequestMatcher_matchesHeadersCaseSensitively() throws {
        requestA.setValue("alphabet", forHTTPHeaderField: "ABC")
        requestB.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestA.matches(otherRequest: requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatch_whenHeadersDiffer() throws {
        requestA.setValue("alphabet", forHTTPHeaderField: "ABC")
        requestA.addValue("алфавит", forHTTPHeaderField: "ABC")

        requestB.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestA.matches(otherRequest: requestB, options: .strict))
    }

    func test_URLRequestMatcher_matchesDuplicateHeaders_inSameOrder() throws {
        requestA.addValue("alphabet", forHTTPHeaderField: "abc")
        requestA.addValue("алфавит", forHTTPHeaderField: "abc")

        requestB.addValue("alphabet", forHTTPHeaderField: "abc")
        requestB.addValue("алфавит", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestA.matches(otherRequest: requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatchDuplicateHeaders_inDifferentOrder() throws {
        requestA.addValue("alphabet", forHTTPHeaderField: "abc")
        requestA.addValue("алфавит", forHTTPHeaderField: "abc")

        requestB.addValue("алфавит", forHTTPHeaderField: "abc")
        requestB.addValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestA.matches(otherRequest: requestB, options: .strict))
    }

    func test_URLRequestMatcher_matches_withEqualBodies() throws {
        requestA.httpBody = "🐡".data(using: .utf8)
        requestB.httpBody = "🐡".data(using: .utf8)

        XCTAssertTrue(requestA.matches(otherRequest: requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatch_whenBodiesDiffer() throws {
        requestA.httpBody = "🍏".data(using: .utf8)
        requestB.httpBody = "🍐".data(using: .utf8)

        XCTAssertFalse(requestA.matches(otherRequest: requestB, options: .strict))
    }

    static var allTests = [
        ("test_URLRequestMatcher_matchesHeadersCaseSensitively",
        test_URLRequestMatcher_matchesHeadersCaseSensitively),
        ("test_URLRequestMatcher_doesNotMatch_whenHeadersDiffer",
        test_URLRequestMatcher_doesNotMatch_whenHeadersDiffer),
        ("test_URLRequestMatcher_matchesDuplicateHeaders_inSameOrder",
        test_URLRequestMatcher_matchesDuplicateHeaders_inSameOrder),
        ("test_URLRequestMatcher_doesNotMatchDuplicateHeaders_inDifferentOrder",
        test_URLRequestMatcher_doesNotMatchDuplicateHeaders_inDifferentOrder),
        ("test_URLRequestMatcher_matches_withEqualBodies",
        test_URLRequestMatcher_matches_withEqualBodies),
        ("test_URLRequestMatcher_doesNotMatch_whenBodiesDiffer",
        test_URLRequestMatcher_doesNotMatch_whenBodiesDiffer)
    ]

}

extension URLRequestMatcherTests {

    fileprivate func request() throws -> URLRequest {
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        return URLRequest(url: url)
    }

}
