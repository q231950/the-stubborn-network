//
//  URLSessionStub.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.07.19.
//

import Foundation

enum NetworkStubError: Error {
    case unexpectedRequest(String)
}

class URLSessionStub: URLSession, StubbornURLSession {
    var stubSource: StubSourceProtocol?
    var recordMode: RecordMode = .playback
    private let endToEndURLSession: URLSession

    init(configuration: URLSessionConfiguration, stubSource: StubSourceProtocol = EphemeralStubSource(), endToEndURLSession: URLSession? = nil) {
        self.endToEndURLSession = endToEndURLSession ?? URLSession(configuration: configuration)
        self.stubSource = stubSource
    }

    func stub(_ request: URLRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let stub = RequestStub(request: request, data: data, response: response, error: error)
        stubSource?.store(stub)
    }
}


extension URLSessionStub {
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        switch recordMode {
        case .recording:
            assert(stubSource != nil)
            return endToEndURLSession.dataTask(with: request, completionHandler: { (data, response, error) in
                let stub = RequestStub(request: request, data:data, response:response, error:error)
                self.stubSource?.store(stub)
                completionHandler(data, response, error)
            })
        case .playback:
            assert(stubSource != nil)
            return stubSource!.dataTask(with: request, completionHandler: completionHandler)
        }
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return dataTask(with: request, completionHandler: completionHandler)
    }
}
