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
        let client = ClientMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client)

        XCTAssertNoThrow(objectUnderTest.stopLoading())
    }

    func test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading() throws {
        let url = try XCTUnwrap(URL(string: "ftp://elbedev.com"))
        let task = URLSession(configuration: .ephemeral).dataTask(with: url)
        let client = ClientMock()
        let objectUnderTest = StubbedSessionURLProtocol(task: task, cachedResponse: nil, client: client)
        objectUnderTest.startLoading()

        XCTAssertEqual(client.didFinishLoadingCount, 1)
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
        ("test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading",
         test_StubbedSessionURLProtocol_notifiesClient_whenFinishedLoading)
    ]
}

class ClientMock: NSObject, URLProtocolClient {
    var didFinishLoadingCount = 0

    func urlProtocol(_ protocol: URLProtocol, wasRedirectedTo request: URLRequest, redirectResponse: URLResponse) { }

    func urlProtocol(_ protocol: URLProtocol, cachedResponseIsValid cachedResponse: CachedURLResponse) { }

    func urlProtocol(_ protocol: URLProtocol, didReceive response: URLResponse, cacheStoragePolicy policy: URLCache.StoragePolicy) { }

    func urlProtocol(_ protocol: URLProtocol, didLoad data: Data) { }

    func urlProtocolDidFinishLoading(_ protocol: URLProtocol) { didFinishLoadingCount += 1 }

    func urlProtocol(_ protocol: URLProtocol, didFailWithError error: Error) { }

    func urlProtocol(_ protocol: URLProtocol, didReceive challenge: URLAuthenticationChallenge) { }

    func urlProtocol(_ protocol: URLProtocol, didCancel challenge: URLAuthenticationChallenge) { }
}
