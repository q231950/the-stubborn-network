//
//  EphemeralStubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 07.08.19.
//

import Foundation

/// This stub source only lives in memory. It is most useful for unit tests where a method
/// is tested against a specific request.
/// `EphemeralStubSource` is normally not used to stub a multitude of requests.
class EphemeralStubSource: StubSourceProtocol {

    var stubs = [RequestStub]()
    var cachedResponses = [CachedResponse]()

    var recordMode: Bool = true

    func store(_ stub: RequestStub, options: RequestMatcherOptions) {
        if !hasStub(stub.request, options: options) {
            stubs.append(stub)
        }
    }

    func hasStub(_ request: URLRequest, options: RequestMatcherOptions) -> Bool {
        stubs.contains { $0.request.matches(request, options: options) }
    }

    func stub(forRequest request: URLRequest, options: RequestMatcherOptions) -> RequestStub? {
        stubs.first { stub -> Bool in
            stub.request.matches(request, options: options)
        }
    }

    func clear() {
        stubs.removeAll()
    }
}
