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
        self.init(task: task, cachedResponse: cachedResponse, client: client, recorder: nil)
    }

    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?, recorder: StubRecording?) {
        self.init()

        internalClient = client
        internalTask = task
        internalRecorder = recorder
    }

    override public func startLoading() {

        let notifyFinished = { self.client?.urlProtocolDidFinishLoading(self) }

        if let request = task?.originalRequest {

            if let stub = stubbornNetwork.stubSource.stub(forRequest: request) {
                playback(stub) { notifyFinished() }
            } else {
                record(task) { data, response, error in
                    self.playback(data: data, response: response, error: error) { notifyFinished() }
                }
            }
        } else {
            notifyFinished()
        }
    }

    override public func stopLoading() { /** Do nothing when asked to stop. */ }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    // MARK: - Boring Internals

    private var stubbornNetwork: StubbornNetwork {
        internalStubbornNetwork ?? StubbornNetwork.standard
    }

    private var recorder: StubRecording {
        if let internalRecorder = internalRecorder {
            return internalRecorder
        } else {
            let urlSession = URLSession(configuration: .ephemeral)
            return StubRecorder(urlSession: urlSession, stubSource: stubbornNetwork.stubSource)
        }
    }

    var internalStubbornNetwork: StubbornNetwork?
    private var internalTask: URLSessionTask?
    private var internalClient: URLProtocolClient?
    private var internalRecorder: StubRecording?
}

extension StubbedSessionURLProtocol {

    fileprivate func playback(_ stub: RequestStub, completion: @escaping () -> Void) {
        playback(data: stub.data, response: stub.response, error: stub.error, completion: completion)
    }

    fileprivate func playback(data: Data?, response: URLResponse?, error: Error?, completion: @escaping () -> Void) {
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        }

        let queue = DispatchQueue(label: "StubbornNetwork URLSession dispatch queue")
        queue.async {
            completion()
        }
    }

    fileprivate func record(_ task: URLSessionTask?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        recorder.record(task, processor: stubbornNetwork.bodyDataProcessor, completion: completion)
    }

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
