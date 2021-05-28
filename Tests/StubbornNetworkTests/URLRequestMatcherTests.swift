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

        XCTAssertTrue(requestA.matches(requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatch_whenHeadersDiffer() throws {
        requestA.setValue("alphabet", forHTTPHeaderField: "ABC")
        requestA.addValue("алфавит", forHTTPHeaderField: "ABC")

        requestB.setValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestA.matches(requestB, options: .strict))
    }

    func test_URLRequestMatcher_matchesDuplicateHeaders_inSameOrder() throws {
        requestA.addValue("alphabet", forHTTPHeaderField: "abc")
        requestA.addValue("алфавит", forHTTPHeaderField: "abc")

        requestB.addValue("alphabet", forHTTPHeaderField: "abc")
        requestB.addValue("алфавит", forHTTPHeaderField: "abc")

        XCTAssertTrue(requestA.matches(requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatchDuplicateHeaders_inDifferentOrder() throws {
        requestA.addValue("alphabet", forHTTPHeaderField: "abc")
        requestA.addValue("алфавит", forHTTPHeaderField: "abc")

        requestB.addValue("алфавит", forHTTPHeaderField: "abc")
        requestB.addValue("alphabet", forHTTPHeaderField: "abc")

        XCTAssertFalse(requestA.matches(requestB, options: .strict))
    }

    func test_URLRequestMatcher_matches_withEqualBodies() throws {
        requestA.httpBody = "🐡".data(using: .utf8)
        requestB.httpBody = "🐡".data(using: .utf8)

        XCTAssertTrue(requestA.matches(requestB, options: .strict))
    }

    func test_URLRequestMatcher_doesNotMatch_whenBodiesDiffer() throws {
        requestA.httpBody = "🍏".data(using: .utf8)
        requestB.httpBody = "🍐".data(using: .utf8)

        XCTAssertFalse(requestA.matches(requestB, options: .strict))
    }

    func test_customMatcherMatches_beforeOtherMatchers() {
        requestA.httpBody = "🍏".data(using: .utf8)
        requestA.httpMethod = "POST"

        requestB.httpBody = "🍐".data(using: .utf8)
        requestB.httpMethod = "GET"

        let comparator: RequestComparator = { request, other -> Bool in
            request.url?.absoluteString == other.url?.absoluteString
        }

        let matches = requestA.matches(requestB, options: RequestMatcherOptions([.requestBody, .custom(match: comparator), .httpMethod]))
        XCTAssertTrue(matches)
    }

    func test_customMatcher_allowsNonCustomMismatches() {
        requestA.httpBody = "🍏".data(using: .utf8)
        requestB.httpBody = "🍐".data(using: .utf8)

        let matchingCustomComparator: RequestComparator = { _, _ -> Bool in
            false
        }

        let matches = requestA.matches(requestB, options: RequestMatcherOptions([.requestBody, .custom(match: matchingCustomComparator)]))
        XCTAssertFalse(matches)
    }

    func test_unsortedUrlParameterMatches() {
        requestA.url = URL(string: "http://elbedev.com?a=1&b=2")
        requestB.url = URL(string: "http://elbedev.com?b=2&a=1")

        XCTAssertTrue(requestA.matches(requestB))
    }

    func test_matchesJSONBody() {
        let JSONData: [String: Any] = [
            "z": 1,
            "a": 0,
            "b": 3
        ]

        requestA.url = URL(string: "http://elbedev.com?a=1&b=2")
        requestA.httpBody = try? JSONSerialization.data(withJSONObject: JSONData, options: .sortedKeys)
        requestB.url = URL(string: "http://elbedev.com?b=2&a=1")
        requestB.httpBody = try? JSONSerialization.data(withJSONObject: JSONData, options: .prettyPrinted)

        XCTAssertNotEqual(requestA.httpBody, requestB.httpBody)
        XCTAssertTrue(requestA.matches(requestB))
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
        test_URLRequestMatcher_doesNotMatch_whenBodiesDiffer),
        ("test_customMatcherMatches_beforeOtherMatchers",
        test_customMatcherMatches_beforeOtherMatchers),
        ("test_customMatcher_allowsNonCustomMismatches",
        test_customMatcher_allowsNonCustomMismatches),
        ("test_unsortedUrlParameterMatches",
        test_unsortedUrlParameterMatches),
        ("test_matchesJSONBody",
         test_matchesJSONBody)
    ]

}

extension URLRequestMatcherTests {

    fileprivate func request() throws -> URLRequest {
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        return URLRequest(url: url)
    }

}
