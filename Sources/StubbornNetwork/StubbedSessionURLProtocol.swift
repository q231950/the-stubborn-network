//
//  URLProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 13.12.19.
//

import Foundation

public class StubbedSessionURLProtocol: URLProtocol {

    lazy var stubSource: StubSourceProtocol = StubbornNetwork.persistentStubSource()
    var t: URLSessionTask? = nil
    public override var task: URLSessionTask? { t }

    var c: URLProtocolClient? = nil
    public override var client: URLProtocolClient? { c }

    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    public convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        self.init()

        c = client
        t = task
    }

    public override var cachedResponse: CachedURLResponse? {
        nil
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override public class func canInit(with task: URLSessionTask) -> Bool {
        true
    }

    override public func startLoading() {
        if let request = task?.originalRequest,
            let stub = stubSource.stub(forRequest: request) {

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override public func stopLoading() {

    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
}
