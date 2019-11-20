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
struct EphemeralStubSource: StubSourceProtocol {
    var expectedDatas = [URLRequest: Data?]()
    var expectedResponses = [URLRequest: URLResponse?]()
    var expectedErrors = [URLRequest: Error?]()
}

/// `EphemeralStubSource` conforms to `StubSourceProtocol`
extension EphemeralStubSource {
    mutating func store(_ stub: RequestStub) {
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
        expectedDatas[request] != nil
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        return URLSessionDataTaskStub(data: expectedDatas[request] ?? nil,
                                      response: expectedResponses[request] ?? nil,
                                      error: expectedErrors[request] ?? nil,
                                      resumeCompletion: completionHandler)
    }
}
