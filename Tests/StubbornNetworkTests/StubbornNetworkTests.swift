import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    func testEphemeralStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.ephemeralStub())
    }

    func testStubbedURLSessionWithConfigurationNotNil() {
        XCTAssertNotNil(StubbornNetwork.stubbed(withConfiguration: .ephemeral))
    }

    func testPersistentStubbedURLSessionNotNil() {
        let testProcessInfo = ProcessInfo()
        XCTAssertNotNil(StubbornNetwork.stubbed(withConfiguration: .persistent(
            name: "Stub",
            path: testProcessInfo.environment["XCTestConfigurationFilePath"]!)))
    }

    func testPersistentStubbedURLSessionFromProcessInfoNotNil() {
        let testProcessInfo = ProcessInfo()

        let processInfo = ProcessInfoStub(stubName: "Stub", stubPath: testProcessInfo.environment["XCTestConfigurationFilePath"]!)

        XCTAssertNotNil(StubbornNetwork.stubbed(withProcessInfo: processInfo))
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
