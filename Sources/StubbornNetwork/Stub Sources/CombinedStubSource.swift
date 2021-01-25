//
//  CombinedStubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.12.19.
//

import Foundation

/// The _Combined Stub Source_ combines multiple _Stub Sources_ into one.
/// It combines the results of each of its sources. If multiple sources
/// return some value, the first source wins and its value is represented
/// by the _Combined Stub Source_.
struct CombinedStubSource: StubSourceProtocol {

    let sources: [StubSourceProtocol]

    var recordMode: Bool {
        sources
            .map { $0.recordMode }
            .contains(true)
    }

    func store(_ stub: RequestStub, options: RequestMatcherOptions) {
        sources.forEach { $0.store(stub, options: options) }
    }

    func hasStub(_ request: URLRequest, options: RequestMatcherOptions) -> Bool {
        sources.contains { $0.hasStub(request, options: options) }
    }

    func stub(forRequest request: URLRequest, options: RequestMatcherOptions) -> RequestStub? {
        sources.first { source -> Bool in
            source.hasStub(request, options: options)
        }?
        .stub(forRequest: request, options: options)
    }

    func clear() {
        sources.forEach { $0.clear() }
    }
}
