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

        let notifyFinished = { self.client?.urlProtocolDidFinishLoading(self) }

        if let request = task?.originalRequest {

            // this basically mimics .recordNew
            if let stub = stubbornNetwork.stubSource.stub(forRequest: request) {
                playback(stub) { notifyFinished() }
            } else {
                record(task) { stub in self.playback(stub) { notifyFinished() } }
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

    var internalStubbornNetwork: StubbornNetwork?
    private var internalTask: URLSessionTask?
    private var internalClient: URLProtocolClient?
    private let urlSession = URLSession(configuration: .ephemeral)
}

extension StubbedSessionURLProtocol {

    fileprivate func playback(_ stub: RequestStub, completion: () -> Void) {
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        }

        completion()
    }

    fileprivate func record(_ task: URLSessionTask?, completion: @escaping (RequestStub) -> Void) {
        guard let task = task, let request = task.originalRequest else { return }

        if task.self.isKind(of: URLSessionDataTask.self) {
            if let url = request.url {
                urlSession.dataTask(with: url) { (data, response, error) in

                    let (preparedRequestBodyData, preparedResponseBodyData) = self.prepareBodyData(requestBodyData: request.httpBody,
                                                                                              responseBodyData: data,
                                                                                              request: request)

                    var preparedRequest = request
                    preparedRequest.httpBody = preparedRequestBodyData

                    let stub = RequestStub(request: preparedRequest,
                                           data: preparedResponseBodyData,
                                           response: response,
                                           error: error)

                    self.stubbornNetwork.stubSource.store(stub)

                    completion(stub)
                }.resume()
            }
        }
    }

    private func prepareBodyData(requestBodyData: Data?, responseBodyData: Data?, request: URLRequest) ->
        (preparedRequestBodyData: Data?, preparedResponseBodyData: Data?) {
            let preparedRequestBodyData, preparedResponseBodyData: Data?
            if let bodyDataProcessor = stubbornNetwork.bodyDataProcessor {
                preparedRequestBodyData = bodyDataProcessor.dataForStoringRequestBody(data: requestBodyData,
                                                                                      of: request)
                preparedResponseBodyData = bodyDataProcessor.dataForStoringResponseBody(data: responseBodyData,
                                                                                        of: request)
            } else {
                preparedRequestBodyData = requestBodyData
                preparedResponseBodyData = responseBodyData
            }
            return (preparedRequestBodyData, preparedResponseBodyData)
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
