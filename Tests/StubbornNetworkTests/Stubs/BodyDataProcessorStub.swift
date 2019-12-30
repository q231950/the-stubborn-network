//
//  BodyDataProcessorStub.swift
//  
//
//  Created by Kim Dung-Pham on 30.12.19.
//

import Foundation
import StubbornNetwork

class TestingDataCollector {
    var dataForStoringRequestBody: Data?
    var dataForStoringResponseBody: Data?
    var dataForDeliveringResponseBody: Data?
}

struct BodyDataProcessorStub: BodyDataProcessor {
    var collector = TestingDataCollector()

    func dataForStoringRequestBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForStoringRequestBody = data
        return "⚡️⚡️⚡️ dataForStoringRequestBody ⚡️⚡️⚡️".data(using: .utf8)
    }

    func dataForStoringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForStoringResponseBody = data
        return "🐠🐠🐠 dataForStoringResponseBody 🐠🐠🐠".data(using: .utf8)
    }

    func dataForDeliveringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForDeliveringResponseBody = data
        return "🐻🐞 dataForDeliveringResponseBody 🐻🐞".data(using: .utf8)
    }

}
