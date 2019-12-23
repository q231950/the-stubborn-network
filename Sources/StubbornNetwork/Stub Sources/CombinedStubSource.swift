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

    func store(_ stub: RequestStub) {
        sources.forEach { $0.store(stub) }
    }

    func hasStub(_ request: URLRequest) -> Bool {
        sources.contains { $0.hasStub(request) }
    }

    func stub(forRequest request: URLRequest) -> RequestStub? {
        sources.first { (source) -> Bool in
            source.hasStub(request)
        }?.stub(forRequest: request)
    }

    func clear() {
        sources.forEach { $0.clear() }
    }

    // TODO: remove this implementation when the declaration gets removed from `StubSourceProtocol`
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        URLSessionDataTaskStub(data: nil, response: nil, error: nil, resumeCompletion: { (_, _, _) -> Void in })
    }

}
