import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StubbornNetworkTests.allTests),
    ]
}
#endif

/// This is a naïve workaround for https://bugs.swift.org/browse/SR-11501
func XCTUnwrap<X>(_ optional: X?) throws -> X {
    optional!
}
