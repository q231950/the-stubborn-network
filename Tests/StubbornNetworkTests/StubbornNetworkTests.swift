import XCTest
@testable import StubbornNetwork

final class StubbornNetworkTests: XCTestCase {

    var processInfo: ProcessInfo!
    var session: URLSession!
    var url: URL!

    override func setUp() {
        super.setUp()

        processInfo = ProcessInfoStub(stubName: "Stub", stubPath: TestHelper.testingStubSourcePath())

        let configuration: URLSessionConfiguration = .ephemeral

        StubbornNetwork.standard.insertStubbedSessionURLProtocol(into: configuration)
        StubbornNetwork.standard.removeBodyDataProcessor()

        session = URLSession(configuration: configuration)

        do {
            url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        } catch {
            XCTFail()
        }
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

    func test_stubbornNetwork_deliversStoredStubs_usingPersistentStubSource() throws {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)

        let stubSource = PersistentStubSource(path: URL(string: "127.0.0.1")!)

        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let expectedResponse: URLResponse? = URLResponse(url: url, mimeType: "text/html", expectedContentLength: 3, textEncodingName: "utf-8")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request,
                               data: "abc".data(using: .utf8),
                               response: expectedResponse,
                               error: nil)
        stubSource.store(stub)

        StubbornNetwork.standard.ephemeralStubSource = stubSource

        session.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse?.url, response?.url)
            XCTAssertNil(error)

            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 0.01)
    }

    func test_stubbornNetwork_deliversStoredStubs_usingEphemeralStubSource() throws {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)

        let stubSource = EphemeralStubSource()

        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let expectedResponse: URLResponse? = URLResponse(url: url, mimeType: "text/html", expectedContentLength: 3, textEncodingName: "utf-8")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request,
                               data: "abc".data(using: .utf8),
                               response: expectedResponse,
                               error: nil)
        stubSource.store(stub)

        StubbornNetwork.standard.ephemeralStubSource = stubSource

        session.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse?.url, response?.url)
            XCTAssertNil(error)

            exp.fulfill()
        }.resume()

        wait(for: [exp], timeout: 0.01)
    }

    static var allTests = [
        ("test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols",
         test_StubbornNetwork_insertsURLProcotolClass_beforeSystemProtocols),
        ("testEphemeralStubbedURLSessionNotNil",
         testEphemeralStubbedURLSessionNotNil),
        ("testPersistentStubbedURLSessionFromProcessInfoNotNil",
         testPersistentStubbedURLSessionFromProcessInfoNotNil),
        ("test_stubbornNetwork_allowsPersistentAndEphemeralStubSources_atTheSameTime",
         test_stubbornNetwork_allowsPersistentAndEphemeralStubSources_atTheSameTime)
    ]
}
