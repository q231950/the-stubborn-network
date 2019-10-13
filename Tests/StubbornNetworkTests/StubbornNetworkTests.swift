import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    var buildDirectory: String!

    override func setUp() {
        super.setUp()

        let testProcessInfo = ProcessInfo()

        let travisBuildDirectory = testProcessInfo.environment["TRAVIS_BUILD_DIR"]
        if let directoryPath = travisBuildDirectory {
            buildDirectory = directoryPath
        } else {
            buildDirectory = testProcessInfo.environment["XCTestConfigurationFilePath"]!
        }
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

    func testCallsClosureWithStub() {
        let exp = expectation(description: "Closure was called")
        _ = StubbornNetwork.stubbed(withConfiguration: .ephemeral, { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 0.1)
    }

    static var allTests = [
        ("testEphemeralStubbedURLSessionNotNil", testEphemeralStubbedURLSessionNotNil),
        ("testCallsClosureWithStub", testCallsClosureWithStub),
        ("testStubbedURLSessionWithConfigurationNotNil", testStubbedURLSessionWithConfigurationNotNil),
        ("testPersistentStubbedURLSessionNotNil", testPersistentStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionFromProcessInfoNotNil", testPersistentStubbedURLSessionFromProcessInfoNotNil),
        ("testPersistentStubbedURLSessionWithNameAndPathNotNil", testPersistentStubbedURLSessionWithNameAndPathNotNil),
        ("testCallsClosureWithStub", testCallsClosureWithStub),
    ]
}
