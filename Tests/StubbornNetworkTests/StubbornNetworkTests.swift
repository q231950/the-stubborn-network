import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {
    func testStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.stubbed())
    }

    static var allTests = [
        ("testStubbedURLSessionNotNil", testStubbedURLSessionNotNil),
    ]
}
