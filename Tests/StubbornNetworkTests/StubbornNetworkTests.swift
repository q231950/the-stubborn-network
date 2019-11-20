import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    var buildDirectory: String!

    override func setUp() {
        super.setUp()

        buildDirectory = TestHelper.testingStubSourcePath()
    }

    func testEphemeralStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.makeEphemeralSession())
    }

    func testStubbedURLSessionWithConfigurationNotNil() {
        XCTAssertNotNil(StubbornNetwork.stubbed(withConfiguration: .ephemeral))
    }

    func testPersistentStubbedURLSessionNotNil() {
        let processInfo = ProcessInfoStub(stubName: "Stub",
                                          stubPath: buildDirectory)

        let location = StubSourceLocation(processInfo: processInfo)

        XCTAssertNotNil(StubbornNetwork.stubbed(
            withConfiguration: .persistent(location: location))
        )
    }

    func testPersistentStubbedURLSessionFromProcessInfoNotNil() {
        let processInfo = ProcessInfoStub(stubName: "Stub",
                                          stubPath: buildDirectory
        )

        XCTAssertNotNil(StubbornNetwork.makePersistentSession(withProcessInfo: processInfo))
    }

    func testPersistentStubbedURLSessionWithNameAndPathNotNil() {
        XCTAssertNotNil(StubbornNetwork.makePersistentSession(withName: "Stub",
                                                              path: buildDirectory)
        )
    }

    static var allTests = [
        ("testEphemeralStubbedURLSessionNotNil", testEphemeralStubbedURLSessionNotNil),
        ("testStubbedURLSessionWithConfigurationNotNil", testStubbedURLSessionWithConfigurationNotNil),
        ("testPersistentStubbedURLSessionNotNil", testPersistentStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionFromProcessInfoNotNil", testPersistentStubbedURLSessionFromProcessInfoNotNil),
        ("testPersistentStubbedURLSessionWithNameAndPathNotNil", testPersistentStubbedURLSessionWithNameAndPathNotNil),
    ]
}
