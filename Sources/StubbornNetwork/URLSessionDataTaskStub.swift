//
//  URLSessionDataTaskMock.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.07.19.
//

import Foundation

class URLSessionDataTaskStub: URLSessionDataTask {
    var resumeCompletion: ((Data?, URLResponse?, Error?) -> Void)
    let data: Data?

    let stubbedResponse: URLResponse?
    override var response: URLResponse? {
        get {
            return stubbedResponse
        }
    }

    let stubbedError: Error?
    override var error: Error? {
        get {
            return stubbedError
        }
    }

    init(request: URLRequest, data: Data?, response: URLResponse?, error: Error?, resumeCompletion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        self.resumeCompletion = resumeCompletion
        self.data = data
        self.stubbedResponse = response
        self.stubbedError = error
    }

    override func resume() {
        resumeCompletion(data, response, error)
    }
}
