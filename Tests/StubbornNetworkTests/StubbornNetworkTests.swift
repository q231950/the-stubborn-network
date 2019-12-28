import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    var processInfo: ProcessInfo!

    override func setUp() {
        super.setUp()

        processInfo = ProcessInfoStub(stubName: "Stub", stubPath: TestHelper.testingStubSourcePath())
    }

    func test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols() {
        let configuration: URLSessionConfiguration = .ephemeral
        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)

        XCTAssertTrue(configuration.protocolClasses?.first == StubbedSessionURLProtocol.self)
    }

    func testEphemeralStubbedURLSessionNotNil() {
        XCTAssertNotNil(StubbornNetwork.standard.ephemeralStubSource)
    }

    func testPersistentStubbedURLSessionFromProcessInfoNotNil() {
        let stubbornNetwork = StubbornNetwork(processInfo: processInfo)

        XCTAssertNotNil(stubbornNetwork.persistentStubSource)
    }

    func test_stubbornNetwork_allowsPersistentAndEphemeralStubSources_atTheSameTime() throws {
        let stubbornNetwork = StubbornNetwork(processInfo: processInfo)

        if let combinedStubSource = stubbornNetwork.stubSource as? CombinedStubSource {
            XCTAssertEqual(combinedStubSource.sources.count, 2)
        }
    }

    static var allTests = [
        ("test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols",
         test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols),
        ("testEphemeralStubbedURLSessionNotNil",
         testEphemeralStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionFromProcessInfoNotNil",
         testPersistentStubbedURLSessionFromProcessInfoNotNil),
        ("test_stubbornNetwork_allowsPersistentAndEphemeralStubSources_atTheSameTime", test_stubbornNetwork_allowsPersistentAndEphemeralStubSources_atTheSameTime)
    ]
}
