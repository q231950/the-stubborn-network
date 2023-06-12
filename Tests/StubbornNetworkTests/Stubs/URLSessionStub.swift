//
//  URLSessionStub.swift
//  
//
//  Created by Kim Dung-Pham on 30.12.19.
//

import Foundation
@testable import StubbornNetwork

/// This is Stub for testing purposes only.
final class URLSessionStub {

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
}

extension URLSessionStub: URLSessionLike {

    /// This is the same function signature as in ``URLSession``
    /// - (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (NS_SWIFT_SENDABLE ^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (Error)?) -> Void) -> URLSessionDataTask {
        defer {
            completionHandler(data, response, error)
        }

        return URLSession(configuration: .ephemeral).dataTask(with: request)
    }
}
