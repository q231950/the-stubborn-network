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
    var bodyDataProcessor: BodyDataProcessor?
    var recordMode: RecordMode = .playback
    private let endToEndURLSession: URLSession
    var stubSource: StubSourceProtocol?

    /// Initializes a URLSessionStub with a stub source and configures a `URLSession` for recording stubs.
    /// - Parameter configuration: When no `endToEndURLSession` is present, this configuration will
    /// be used to create a `URLSession`
    /// for performing the actual network requests when recording stubs
    /// - Parameter stubSource: A stub source to use for fetching and storing stubs
    /// - Parameter endToEndURLSession: This `URLSession` can be passed in for making the actual network requests when
    /// reording new stubs
    init(configuration: URLSessionConfiguration = .ephemeral,
         stubSource: StubSourceProtocol = EphemeralStubSource(),
         endToEndURLSession: URLSession? = nil) {
        self.endToEndURLSession = endToEndURLSession ?? URLSession(configuration: configuration)
        self.stubSource = stubSource
    }

    func stub(_ request: URLRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let (preparedRequestBodyData, preparedResponseBodyData) = prepareBodyData(requestBodyData: request.httpBody, responseBodyData: data, request: request)

        var preparedRequest = request
        preparedRequest.httpBody = preparedRequestBodyData

        let stub = RequestStub(request: preparedRequest,
                               data: preparedResponseBodyData,
                               response: response,
                               error: error)
        stubSource?.store(stub)
    }

    func prepareBodyData(requestBodyData: Data?, responseBodyData: Data?, request: URLRequest) -> (preparedRequestBodyData: Data?, preparedResponseBodyData: Data?) {
        let preparedRequestBodyData, preparedResponseBodyData: Data?
        if let bodyDataProcessor = bodyDataProcessor {
            preparedRequestBodyData = bodyDataProcessor.dataForStoringRequestBody(data: requestBodyData, of: request)
            preparedResponseBodyData = bodyDataProcessor.dataForStoringResponseBody(data: responseBodyData, of: request)
        } else {
            preparedRequestBodyData = requestBodyData
            preparedResponseBodyData = responseBodyData
        }
        return (preparedRequestBodyData, preparedResponseBodyData)
    }
}

extension URLSessionStub {
    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
            switch recordMode {
            case .recording:
                assert(stubSource != nil)
                return endToEndURLSession.dataTask(with: request, completionHandler: { (data, response, error) in
                    self.stub(request, data: data, response: response, error: error)
                    completionHandler(data, response, error)
                })
            case .playback:
                assert(stubSource != nil)
                return stubSource!.dataTask(with: request, completionHandler: {(data, response, error) in
                    let processedData = self.bodyDataProcessor?.dataForDeliveringResponseBody(data: data, of: request)
                    let preparedData = processedData ?? data
                    completionHandler(preparedData, response, error)
                })
            }
    }

    override func dataTask(with url: URL,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {
            let request = URLRequest(url: url)
            return dataTask(with: request, completionHandler: completionHandler)
    }
}
