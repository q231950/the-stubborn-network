//
//  StubbedSessionURLProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 13.12.19.
//

import Foundation

/// This URL protocol enables standard URL sessions to return stubbed responses.
///
/// In order to use the protocol it needs to be inserted into the `URLSession` instance configuration's `protcolClasses`
/// before the configuration is passed into the initializer of `URLSession`. The Stubborn Network has a convenience method
/// for inserting the class into a given `URLSessionConfiguration`.
public class StubbedSessionURLProtocol: URLProtocol {

    public override var task: URLSessionTask? { internalTask }
    public override var client: URLProtocolClient? { internalClient }

    public override class func canInit(with request: URLRequest) -> Bool {
        return canInit(with: request.url?.scheme)
    }

    override public class func canInit(with task: URLSessionTask) -> Bool {
        return canInit(with: task.originalRequest?.url?.scheme)
    }

    /// This is a convenience initializer defined in URLProtocol.
    public convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        self.init()

        internalClient = client
        internalTask = task
    }

    override public func startLoading() {
        if let request = task?.originalRequest,
            let stub = stubbornNetwork.stubSource.stub(forRequest: request) {

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() { /** Do nothing when asked to stop. */ }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    // MARK: - Boring Internals

    private var stubbornNetwork: StubbornNetwork {
        internalStubbornNetwork ?? StubbornNetwork.standard
    }

    var internalStubbornNetwork: StubbornNetwork?
    private var internalTask: URLSessionTask?
    private var internalClient: URLProtocolClient?
}

extension StubbedSessionURLProtocol {

    /// Gets the information about whether or not a URL scheme is supported by this protocol.
    ///
    /// - Parameter scheme: The scheme to check support for
    fileprivate class func canInit(with scheme: String?) -> Bool {
        switch scheme {
        case "http", "https":
            return true
        default:
            return false
        }
    }
}