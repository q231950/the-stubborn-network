//
//  URLSessionStub.swift
//  
//
//  Created by Kim Dung-Pham on 30.12.19.
//

import Foundation

/// Instances of this `URLSessionStub` can double as URL sessions.
/// Some attributes of the _Foundation_ `URLSession` can be stubbed for testing purposes.
class URLSessionStub: URLSession {

    /// When requesting a data task from the `URLSessionStub` it will return one with a stubbed `originalRequest`
    let originalRequest: URLRequest?

    /// When requesting a data task from the `URLSessionStub` it allows to stub the
    /// data, response and error of the `completionHandler`
    let data: Data?
    let response: URLResponse?
    let error: Error?

    init(originalRequest: URLRequest?, data: Data?, response: URLResponse?, error: Error?) {
        self.originalRequest = originalRequest
        self.data = data
        self.response = response
        self.error = error
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataTaskStub(originalRequest: originalRequest,
                                      data: data, response: response, error: error, resumeCompletion: completionHandler)
    }
}
