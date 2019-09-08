//
//  EphemeralStubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 07.08.19.
//

import Foundation

class EphemeralStubSource: StubSourceProtocol {
    var expectedDatas = [URLRequest: Data?]()
    var expectedResponses = [URLRequest: URLResponse?]()
    var expectedErrors = [URLRequest: Error?]()

    convenience init() {
        self.init(url: URL(string: "127.0.0.1")!)
    }

    required init(url: URL) {}

    func store(_ stub: RequestStub) {
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

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskStub(request: request,
                                      data: expectedDatas[request] ?? nil,
                                      response: expectedResponses[request] ?? nil,
                                      error:expectedErrors[request] ?? nil,
                                      resumeCompletion: completionHandler)
    }
}
