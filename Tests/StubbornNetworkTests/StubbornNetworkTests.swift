import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {
    func testEphemeralStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.stubbed(withConfiguration: .ephemeral))
    }

    func testPersistentStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.stubbed(withConfiguration: .persistent(name: "Stub", path: "127.0.0.1")))
    }

    func testCallsClosureWithStub() {
        let exp = expectation(description: "Closure was called")
        let _ = StubbornNetwork.stubbed(withConfiguration: .ephemeral,  { stub in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 0.1)
    }

    static var allTests = [
        ("testEphemeralStubbedURLSessionNotNil", testEphemeralStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionNotNil", testPersistentStubbedURLSessionNotNil),
        ("testCallsClosureWithStub", testCallsClosureWithStub),
    ]
}
