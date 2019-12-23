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
    var expectedDatas = [URLRequest: Data?]()
    var expectedResponses = [URLRequest: URLResponse?]()
    var expectedErrors = [URLRequest: Error?]()

    func store(_ stub: RequestStub) {
        stubs.append(stub)

        if let data = stub.data {
            expectedDatas[stub.request] = data
        }

        if let response = stub.response {
            expectedResponses[stub.request] = response
        }
        if let error = stub.error {
            expectedErrors[stub.request] = error
        }
    }

    func hasStub(_ request: URLRequest) -> Bool {
        stubs.contains(where: { $0.request == request })
    }

    func stub(forRequest request: URLRequest) -> RequestStub? {
        stubs.first { (stub) -> Bool in
            stub.request.matches(request: request)
        }
    }

    func clear() {
	stubs.removeAll()
	expectedDatas.removeAll()
	expectedResponses.removeAll()
	expectedErrors.removeAll()
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        return URLSessionDataTaskStub(data: expectedDatas[request] ?? nil,
                                      response: expectedResponses[request] ?? nil,
                                      error: expectedErrors[request] ?? nil,
                                      resumeCompletion: completionHandler)
    }
}
