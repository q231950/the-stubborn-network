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

    func cache(response: CachedResponse) {
        // TODO ...
    }

    func cachedResponse(forRequest request: URLRequest) -> CachedResponse? {
        nil
    }

    func hasCachedResponse(_ request: URLRequest) -> Bool {
        false
    }

    var stubs = [RequestStub]()

    func store(_ stub: RequestStub, options: RequestMatcherOptions?) {
        if !hasStub(stub.request, options: options) {
            stubs.append(stub)
        }
    }

    func hasStub(_ request: URLRequest, options: RequestMatcherOptions?) -> Bool {
        stubs.contains(where: { $0.request.matches(otherRequest: request, options: options) })
    }

    func stub(forRequest request: URLRequest, options: RequestMatcherOptions?) -> RequestStub? {
        stubs.first { (stub) -> Bool in
            stub.request.matches(otherRequest: request, options: options)
        }
    }

    func clear() {
        stubs.removeAll()
    }

}
