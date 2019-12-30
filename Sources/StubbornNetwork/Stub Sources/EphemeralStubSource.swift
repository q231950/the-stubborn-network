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

    func store(_ stub: RequestStub) {
        stubs.append(stub)
    }

    func hasStub(_ request: URLRequest) -> Bool {
        stubs.contains(where: { $0.request.matches(request: request) })
    }

    func stub(forRequest request: URLRequest) -> RequestStub? {
        stubs.first { (stub) -> Bool in
            stub.request.matches(otherRequest: request)
        }
    }

    func clear() {
        stubs.removeAll()
    }

}
