//
//  File.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.10.19.
//

import Foundation
@testable import StubbornNetwork

class TestingDataCollector {
    var dataForStoringRequestBody: Data?
    var dataForStoringResponseBody: Data?
    var dataForDeliveringResponseBody: Data?
}

struct TestingBodyDataProcessor: BodyDataProcessor {
    var collector = TestingDataCollector()

    func dataForStoringRequestBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForStoringRequestBody = data
        guard let unwrappedData = data, let text = String(data: unwrappedData, encoding: .utf8) else {
            return data
        }
        return text.replacingOccurrences(of: "x", with: "").data(using: .utf8)
    }

    func dataForStoringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForStoringResponseBody = data
        guard let unwrappedData = data, let text = String(data: unwrappedData, encoding: .utf8) else {
            return data
        }
        return text.replacingOccurrences(of: "y", with: "").data(using: .utf8)
    }

    func dataForDeliveringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        collector.dataForDeliveringResponseBody = data

        guard let unwrappedData = data, let text = String(data: unwrappedData, encoding: .utf8) else {
            return data
        }

        return text.replacingOccurrences(of: "z", with: "").data(using: .utf8)
    }
}
