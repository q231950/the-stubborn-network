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
        combinedStubSource.store(requestStub, options: .strict)

        XCTAssertTrue(source1.hasStub(request, options: .strict))
        XCTAssertTrue(source2.hasStub(request, options: .strict))
    }

    func test_combinedStubSource_isNotInRecordMode_whenOneOfItsSourcesIsNotInRecordMode() {
        // given
        let source1 = EphemeralStubSource(recordMode: false)
        let source2 = EphemeralStubSource()
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        XCTAssertFalse(combinedStubSource.recordMode)
    }

    func test_combinedStubSource_isInRecordMode_whenAllItsSourcesAreInRecordMode() {
        // given
        let source1 = EphemeralStubSource(recordMode: true)
        let source2 = EphemeralStubSource(recordMode: true)
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        XCTAssertTrue(combinedStubSource.recordMode)
    }

    func test_combinedStubSource_isNotInRecordMode_whenNoneOfItsSourcesIsInRecordMode() {
        // given
        let source1 = EphemeralStubSource(recordMode: false)
        let source2 = EphemeralStubSource(recordMode: false)
        let combinedStubSource = CombinedStubSource(sources: [source1, source2])

        XCTAssertFalse(combinedStubSource.recordMode)
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
        source2.store(requestStub, options: .strict)

        XCTAssertTrue(combinedStubSource.hasStub(request, options: .strict))
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
        source1.store(requestStub, options: .strict)
        source2.store(requestStub, options: .strict)

        combinedStubSource.clear()

        XCTAssertFalse(source1.hasStub(request, options: .strict))
        XCTAssertFalse(source2.hasStub(request, options: .strict))
    }

    static var allTests = [
        ("test_CombinedStubSource_storesToItsSources",
        test_CombinedStubSource_storesToItsSources),
        ("test_CombinedStubSource_returnsIfAnyOfItsSourcesHasAStub",
        test_CombinedStubSource_returnsIfAnyOfItsSourcesHasAStub),
        ("test_CombinedStubSource_clearsAllOfItsSources",
        test_CombinedStubSource_clearsAllOfItsSources),
        ("test_CombinedStubSource_clearsAllOfItsSources",
        test_CombinedStubSource_clearsAllOfItsSources),
        ("test_combinedStubSource_isNotInRecordMode_whenOneOfItsSourcesIsNotInRecordMode",
         test_combinedStubSource_isNotInRecordMode_whenOneOfItsSourcesIsNotInRecordMode),
         ("test_combinedStubSource_isInRecordMode_whenAllItsSourcesAreInRecordMode",
         test_combinedStubSource_isInRecordMode_whenAllItsSourcesAreInRecordMode),
         ("test_combinedStubSource_isNotInRecordMode_whenNoneOfItsSourcesIsInRecordMode",
         test_combinedStubSource_isNotInRecordMode_whenNoneOfItsSourcesIsInRecordMode)
    ]
}
