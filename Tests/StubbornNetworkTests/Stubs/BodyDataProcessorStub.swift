//
//  BodyDataProcessorStub.swift
//  
//
//  Created by Kim Dung-Pham on 30.12.19.
//

import Foundation
import StubbornNetwork

struct BodyDataProcessorStub: BodyDataProcessor {
    func dataForStoringRequestBody(data: Data?, of request: URLRequest) -> Data? {
        "⚡️⚡️⚡️ dataForStoringRequestBody ⚡️⚡️⚡️".data(using: .utf8)
    }

    func dataForStoringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        "🐠🐠🐠 dataForStoringResponseBody 🐠🐠🐠".data(using: .utf8)
    }

    func dataForDeliveringResponseBody(data: Data?, of request: URLRequest) -> Data? {
        "🐻🐞 dataForDeliveringResponseBody 🐻🐞".data(using: .utf8)
    }

}
