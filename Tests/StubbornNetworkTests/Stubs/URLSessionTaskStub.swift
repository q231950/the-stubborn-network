//
//  URLSessionTaskStub.swift
//  
//
//  Created by Kim Dung-Pham on 28.12.19.
//

import Foundation

class URLSessionDataTaskStub: URLSessionDataTask {
    let stubbedOriginalRequest: URLRequest?
    override var originalRequest: URLRequest? {
        stubbedOriginalRequest
    }

    let stubbedData: Data?

    let stubbedResponse: URLResponse?
    override var response: URLResponse? {
        stubbedResponse
    }

    let stubbedError: Error?
    override var error: Error? {
        stubbedError
    }
    var resumeCompletion: ((Data?, URLResponse?, Error?) -> Void)


    convenience init(originalRequest: URLRequest?) {
        self.init(originalRequest: originalRequest, data: nil, response: nil, error: nil, resumeCompletion: {
        (_, _, _) in
        })
    }

    init(originalRequest: URLRequest?,
         data: Data?,
         response: URLResponse?,
         error: Error?,
         resumeCompletion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        self.stubbedOriginalRequest = originalRequest
        self.stubbedData = data
        self.stubbedResponse = response
        self.stubbedError = error
        self.resumeCompletion = resumeCompletion
    }

    override func resume() {
        resumeCompletion(stubbedData, response, error)
    }
}
