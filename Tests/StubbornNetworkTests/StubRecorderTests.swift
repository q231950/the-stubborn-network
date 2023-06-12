//
//  StubRecorderTests.swift
//  
//
//  Created by Kim Dung-Pham on 28.12.19.
//

import XCTest
@testable import StubbornNetwork

class StubRecorderTests: XCTestCase {

    private let stubSource = EphemeralStubSource()
    private var expectedData: Data!
    private var expectedResponse: HTTPURLResponse!
    private var url: URL!

    override func setUp() {
        super.setUp()

        expectedData = "abc".data(using: .utf8)
        url = URL(string: "http://elbedev.com")!
        expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: ["a": "b"])
    }

    // MARK: Verify request responses

    func test_stubRecorder_CompletesWithOriginalDataAndResponse() throws {
        let urlSession = URLSessionStub(originalRequest: URLRequest(url: url),
                                        data: expectedData,
                                        response: expectedResponse,
                                        error: nil)

        let recorder = StubRecorder(stubSource: stubSource, urlSession: urlSession)
        let task = urlSession.dataTask(with: URLRequest(url: url), completionHandler: { _, _, _ in
        })

        recorder.record(task, processor: nil, options: .strict) { (data, response, error) in
            XCTAssertEqual(data, self.expectedData)
            XCTAssertEqual(response, self.expectedResponse)
            XCTAssertNil(error)
        }
    }

    func test_stubRecorder_CompletesWithOriginalError() throws {
        let urlSession = URLSessionStub(originalRequest: URLRequest(url: url),
                                        data: nil,
                                        response: nil,
                                        error: TestError.expected)

        let recorder = StubRecorder(stubSource: stubSource, urlSession: urlSession)
        let task = urlSession.dataTask(with: URLRequest(url: url), completionHandler: { _, _, _ in
        })

        recorder.record(task, processor: nil, options: .strict) { (_, _, error) in
            XCTAssertEqual(error?.localizedDescription, TestError.expected.localizedDescription)
        }
    }

    // MARK: Verify recording of responses

    func test_stubRecorder_RecordsDataAndResponse() throws {
        let urlSession = URLSessionStub(originalRequest: URLRequest(url: url),
                                        data: expectedData,
                                        response: expectedResponse,
                                        error: nil)

        let recorder = StubRecorder(stubSource: stubSource, urlSession: urlSession)
        let task = urlSession.dataTask(with: URLRequest(url: url), completionHandler: { _, _, _ in
        })

        recorder.record(task, processor: nil, options: .strict) { (_, _, _) in }

        XCTAssertEqual(self.stubSource.stubs.first?.responseData, self.expectedData)
        XCTAssertEqual(self.stubSource.stubs.first?.response, self.expectedResponse)
    }

    func test_stubRecorder_RecordsError() throws {
        let urlSession = URLSessionStub(originalRequest: URLRequest(url: url),
                                        data: nil,
                                        response: nil,
                                        error: TestError.expected)

        let recorder = StubRecorder(stubSource: stubSource, urlSession: urlSession)
        let task = urlSession.dataTask(with: URLRequest(url: url), completionHandler: { _, _, _ in
        })

        recorder.record(task, processor: nil, options: .strict) { (_, _, _) in }

        let stub = try XCTUnwrap(self.stubSource.stubs.first)
        XCTAssertEqual(stub.error?.localizedDescription, TestError.expected.localizedDescription)
    }

    // MARK: Verify Body Data Processor Activity

    func test_stubRecorder_passesDataThroughBodyDataProcessor_beforeStoringStub() throws {
        let urlSession = URLSessionStub(originalRequest: URLRequest(url: url),
                                        data: expectedData,
                                        response: expectedResponse,
                                        error: nil)

        let recorder = StubRecorder(stubSource: stubSource, urlSession: urlSession)
        let task = urlSession.dataTask(with: URLRequest(url: url), completionHandler: { _, _, _ in
        })

        let bodyDataProcessorStub = BodyDataProcessorStub()
        recorder.record(task, processor: bodyDataProcessorStub, options: .strict) { (_, _, _) in }

        let stub = try XCTUnwrap(self.stubSource.stubs.first)
        XCTAssertEqual(String(data: try XCTUnwrap(stub.responseData), encoding: .utf8), "🐠🐠🐠 dataForStoringResponseBody 🐠🐠🐠")
        XCTAssertEqual(String(data: try XCTUnwrap(stub.request.httpBody), encoding: .utf8), "⚡️⚡️⚡️ dataForStoringRequestBody ⚡️⚡️⚡️")
    }

    static var allTests = [
        ("test_stubRecorder_CompletesWithOriginalDataAndResponse",
         test_stubRecorder_CompletesWithOriginalDataAndResponse),
        ("test_stubRecorder_CompletesWithOriginalError",
         test_stubRecorder_CompletesWithOriginalError),
        ("test_stubRecorder_RecordsDataAndResponse",
         test_stubRecorder_RecordsDataAndResponse),
        ("test_stubRecorder_RecordsDataAndResponse",
         test_stubRecorder_RecordsDataAndResponse),
        ("test_stubRecorder_RecordsError",
         test_stubRecorder_RecordsError),
        ("test_stubRecorder_passesDataThroughBodyDataProcessor_beforeStoringStub",
         test_stubRecorder_passesDataThroughBodyDataProcessor_beforeStoringStub)
    ]

}
