//
//  CombinedStubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.12.19.
//

import Foundation

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

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        URLSessionDataTaskStub(data: nil, response: nil, error: nil, resumeCompletion: { (_, _, _) -> Void in })
    }


}
