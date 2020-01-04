//
//  StubbedSessionURLProtocolTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.12.19.
//

import XCTest
@testable import StubbornNetwork

class StubbedSessionURLProtocolTests: XCTestCase {

    func test_StubbedSessionURLProtocol_canInitialize_withHTTPRequests() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "http://elbedev.com")))
        XCTAssertTrue(StubbedSessionURLProtocol.canInit(with: request))
    }

    func test_StubbedSessionURLProtocol_cannotInitialize_withFTPRequests() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "ftp://elbedev.com")))
        XCTAssertFalse(StubbedSessionURLProtocol.canInit(with: request))
    }

    func test_StubbedSessionURLProtocol_canInitialize_withHTTPURLSessionTasks() throws {
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        XCTAssertTrue(StubbedSessionURLProtocol.canInit(with: task))
    }

    func test_StubbedSessionURLProtocol_cannotInitialize_withFTPURLSessionTasks() throws {
        let url = try XCTUnwrap(URL(string: "ftp://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        XCTAssertFalse(StubbedSessionURLProtocol.canInit(with: task))
    }

    func test_StubbedSessionURLProtocol_returnsACanonicalRequest() throws {
        let url = try XCTUnwrap(URL(string: "http://elbedev.com"))
        let request = URLRequest(url: url)
        XCTAssertEqual(StubbedSessionURLProtocol.canonicalRequest(for: request), request)
    }

    func test_StubbedSessionURLProtocol_stopLoading_doesNotEndTheWorld() throws {
        let url = try XCTUnwrap(URL(string: "ftp://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client)

        XCTAssertNoThrow(objectUnderTest.stopLoading())
    }

    func test_StubbedSessionURLProtocol_playsBackDataAndResponse_whenItFindsMatchingStub() throws {
        // given there is a stub for the given request
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let recorder = StubRecorderMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client, recorder: recorder)
        let ephemeralStubSource = EphemeralStubSource()
        let expectedData = "🌈".data(using: .utf8)
        let expectedResponse = URLResponse()
        let stub = RequestStub(request: task.originalRequest!, data: expectedData, response: expectedResponse, error: nil)

        objectUnderTest.internalStubbornNetwork = StubbornNetwork(processInfo: ProcessInfo(), ephemeralStubSource)
        ephemeralStubSource.store(stub, options: .strict)
        objectUnderTest.startLoading()

        XCTAssertEqual(client.didLoadData, expectedData)
        XCTAssertEqual(client.didReceiveResponse, expectedResponse)
    }

    func test_StubbedSessionURLProtocol_playsBackError_whenItFindsMatchingStub() throws {
        // given there is a stub for the given request
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let recorder = StubRecorderMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client, recorder: recorder)
        let ephemeralStubSource = EphemeralStubSource()
        let stub = RequestStub(request: task.originalRequest!,
                               data: nil,
                               response: nil,
                               error: TestError.expected)

        objectUnderTest.internalStubbornNetwork = StubbornNetwork(processInfo: ProcessInfo(), ephemeralStubSource)
        ephemeralStubSource.store(stub, options: .strict)
        objectUnderTest.startLoading()

        XCTAssertEqual(client.didFailWithError?.localizedDescription,
                       TestError.expected.localizedDescription)
    }

    func test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading() throws {
        // given there is a stub for the given request
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client)
        let ephemeralStubSource = EphemeralStubSource()
        let stub = RequestStub(request: task.originalRequest!)

        objectUnderTest.internalStubbornNetwork = StubbornNetwork(processInfo: ProcessInfo(), ephemeralStubSource)
        ephemeralStubSource.store(stub, options: .strict)
        objectUnderTest.startLoading()

        XCTAssertEqual(client.didFinishLoadingCount, 1)
    }

    func test_StubbedSessionURLProtocol_doesNotRecord_whenItFindsMatchingStub() throws {
        // given there is a stub for the given request
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let recorder = StubRecorderMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client, recorder: recorder)
        let ephemeralStubSource = EphemeralStubSource()
        let stub = RequestStub(request: task.originalRequest!)

        objectUnderTest.internalStubbornNetwork = StubbornNetwork(processInfo: ProcessInfo(), ephemeralStubSource)
        ephemeralStubSource.store(stub, options: .strict)
        objectUnderTest.startLoading()

        XCTAssertEqual(recorder.recordCount, 0)
    }

    func test_StubbedSessionURLProtocol_records_whenItFindsNoMatchingStub() throws {
        // given there is no stub for the given request
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let recorder = StubRecorderMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client, recorder: recorder)

        objectUnderTest.internalStubbornNetwork = StubbornNetwork(processInfo: ProcessInfo(), EphemeralStubSource())
        objectUnderTest.startLoading()

        XCTAssertEqual(recorder.recordCount, 1)
    }

    func test_StubbedSessionURLProtocol_hasDefaultStubRecorder() throws {
        let url = try XCTUnwrap(URL(string: "https://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = URLProtocolClientStub()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client, recorder: nil)

        XCTAssertNotNil(objectUnderTest.recorder)
    }

    static var allTests = [
        ("test_StubbedSessionURLProtocol_canInitialize_withHTTPRequests",
         test_StubbedSessionURLProtocol_canInitialize_withHTTPRequests),
        ("test_StubbedSessionURLProtocol_cannotInitialize_withFTPRequests",
         test_StubbedSessionURLProtocol_cannotInitialize_withFTPRequests),
        ("test_StubbedSessionURLProtocol_canInitialize_withHTTPURLSessionTasks",
         test_StubbedSessionURLProtocol_canInitialize_withHTTPURLSessionTasks),
        ("test_StubbedSessionURLProtocol_cannotInitialize_withFTPURLSessionTasks",
         test_StubbedSessionURLProtocol_cannotInitialize_withFTPURLSessionTasks),
        ("test_StubbedSessionURLProtocol_returnsACanonicalRequest",
         test_StubbedSessionURLProtocol_returnsACanonicalRequest),
        ("test_StubbedSessionURLProtocol_stopLoading_doesNotEndTheWorld",
         test_StubbedSessionURLProtocol_stopLoading_doesNotEndTheWorld),
        ("test_StubbedSessionURLProtocol_playsBackDataAndResponse_whenItFindsMatchingStub",
         test_StubbedSessionURLProtocol_playsBackDataAndResponse_whenItFindsMatchingStub),
        ("test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading",
         test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading),
        ("test_StubbedSessionURLProtocol_records_whenItFindsNoMatchingStub", test_StubbedSessionURLProtocol_records_whenItFindsNoMatchingStub)
    ]
}

class URLProtocolClientStub: NSObject, URLProtocolClient {
    var didFinishLoadingCount = 0
    var didLoadData: Data?
    var didReceiveResponse: URLResponse?
    var didFailWithError: Error?

    func urlProtocol(_ protocol: URLProtocol, wasRedirectedTo request: URLRequest, redirectResponse: URLResponse) { }

    func urlProtocol(_ protocol: URLProtocol, cachedResponseIsValid cachedResponse: CachedURLResponse) { }

    func urlProtocol(_ protocol: URLProtocol, didReceive response: URLResponse, cacheStoragePolicy policy: URLCache.StoragePolicy) {
        didReceiveResponse = response
    }

    func urlProtocol(_ protocol: URLProtocol, didLoad data: Data) {
        didLoadData = data
    }

    func urlProtocolDidFinishLoading(_ protocol: URLProtocol) { didFinishLoadingCount += 1 }

    func urlProtocol(_ protocol: URLProtocol, didFailWithError error: Error) {
        didFailWithError = error
    }

    func urlProtocol(_ protocol: URLProtocol, didReceive challenge: URLAuthenticationChallenge) { }

    func urlProtocol(_ protocol: URLProtocol, didCancel challenge: URLAuthenticationChallenge) { }
}

class StubRecorderMock: StubRecording {
    var recordCount = 0

    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                options: RequestMatcherOptions?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        recordCount += 1
        completion("⚡️".data(using: .utf8), URLResponse(), nil)
    }
}
