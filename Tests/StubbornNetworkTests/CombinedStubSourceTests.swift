//
//  CombinedStubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.12.19.
//

import XCTest
@testable import StubbornNetwork

class CombinedStubSourceTests: XCTestCase {

    func test_CombinedStubSource_storesToItsSources() throws {
        // given
        let source1 = EphemeralStubSource()
        let source2 = EphemeralStubSource()
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        // when
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let request = URLRequest(url: url)
        let requestStub = RequestStub(request: request)
        combinedStubSource.store(requestStub)

        XCTAssertTrue(source1.hasStub(request))
        XCTAssertTrue(source2.hasStub(request))
    }

    func test_CombinedStubSource_returnsIfAnyOfItsSourcesHasAStub() throws {
        // given
        let source1 = EphemeralStubSource()
        let source2 = EphemeralStubSource()
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        // when
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let request = URLRequest(url: url)
        let requestStub = RequestStub(request: request)
        source2.store(requestStub)

        XCTAssertTrue(combinedStubSource.hasStub(request))
    }

    func test_CombinedStubSource_clearsAllOfItsSources() throws {
        // given
        let source1 = EphemeralStubSource()
        let source2 = EphemeralStubSource()
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        // when
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let request = URLRequest(url: url)
        let requestStub = RequestStub(request: request)
        source1.store(requestStub)
        source2.store(requestStub)

        combinedStubSource.clear()

        XCTAssertFalse(source1.hasStub(request))
        XCTAssertFalse(source2.hasStub(request))
    }

    static var allTests = [
        ("test_CombinedStubSource_storesToItsSources", test_CombinedStubSource_storesToItsSources),
        ("test_CombinedStubSource_returnsIfAnyOfItsSourcesHasAStub", test_CombinedStubSource_returnsIfAnyOfItsSourcesHasAStub),
        ("test_CombinedStubSource_clearsAllOfItsSources", test_CombinedStubSource_clearsAllOfItsSources),
        ("test_CombinedStubSource_clearsAllOfItsSources", test_CombinedStubSource_clearsAllOfItsSources)
    ]
}
