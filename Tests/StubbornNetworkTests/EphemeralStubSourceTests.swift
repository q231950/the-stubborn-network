//
//  EphemeralStubSourceTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

class EphemeralStubSourceTests: XCTestCase {

    func testInitializer() {
        let stubSource = EphemeralStubSource()

        XCTAssertNotNil(stubSource)
    }

    func testStoresStub() {
        let exp = expectation(description: "Wait for data task completion")
        let expectedData = "abc".data(using: .utf8)
        let expectedResponse = HTTPURLResponse()

        let url = URL(string: "127.0.0.1")!

        let stubSource = EphemeralStubSource()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["B": "BBB"]

        let stub = RequestStub(request: request,
                               data: "abc".data(using: .utf8),
                               response: expectedResponse,
                               error: TestError.expected)
        stubSource.store(stub)

        let dataTask = stubSource.dataTask(with: request) { (data, response, error) in
            XCTAssertEqual(expectedData, data)
            XCTAssertEqual(expectedResponse, response)
            XCTAssertEqual(TestError.expected.localizedDescription, error?.localizedDescription)

            exp.fulfill()
        }
        dataTask.resume()

        wait(for: [exp], timeout: 0.1)
    }

    static var allTests = [
        ("testInitializer", testInitializer),
    ]
}
