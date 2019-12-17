import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    var buildDirectory: String!

    override func setUp() {
        super.setUp()

        buildDirectory = TestHelper.testingStubSourcePath()
    }

    func test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols() {
        let configuration: URLSessionConfiguration = .ephemeral
        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)

        XCTAssertTrue(configuration.protocolClasses?.first == StubbedSessionURLProtocol.self)
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

        let location = StubSourceLocation(processInfo: processInfo)!

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
        ("test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols",
         test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols),
        ("testEphemeralStubbedURLSessionNotNil", testEphemeralStubbedURLSessionNotNil),
        ("testStubbedURLSessionWithConfigurationNotNil", testStubbedURLSessionWithConfigurationNotNil),
        ("testPersistentStubbedURLSessionNotNil", testPersistentStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionFromProcessInfoNotNil", testPersistentStubbedURLSessionFromProcessInfoNotNil),
        ("testPersistentStubbedURLSessionWithNameAndPathNotNil", testPersistentStubbedURLSessionWithNameAndPathNotNil),
    ]
}
