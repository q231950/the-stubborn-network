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

}
