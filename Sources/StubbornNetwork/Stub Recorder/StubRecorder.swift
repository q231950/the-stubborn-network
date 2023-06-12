//
//  StubRecorder.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.12.19.
//

import Foundation

extension URLSession: URLSessionLike {}

/// A marker pseudo protocol to simplify testing by avoiding the concrete ``URLSession`` type.
/// ``URLSession`` already conforms to this protocol as you can see in the _extension URLSession: URLSessionLike_.
protocol URLSessionLike {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
}

/// The Stub Recorder records stubs by making an actual request and storing the response in a Stub Source.
struct StubRecorder: StubRecording {

    /// The _Stub Source_ dictates how the stub will be stored and where
    let stubSource: StubSourceProtocol

    /// This `URLSessionLike`, commonly a `URLSession` is used to get the actual data, response and error
    /// for the `URLSessionTask`s which are recorded.
    /// `URLSessionLike` is used instead of a concrete ``URLSession`` here to simplify testing.
    let urlSession: URLSessionLike

    init(stubSource: StubSourceProtocol, urlSession: URLSessionLike) {
        self.stubSource = stubSource
        self.urlSession = urlSession
    }

    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                options: RequestMatcherOptions,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        guard let task = task, let request = task.originalRequest else { return }

        if task.self.isKind(of: URLSessionDataTask.self) {
            urlSession.dataTask(with: request) { data, response, error in

                let (prepRequestBodyData, prepResponseBodyData) = self.prepare(requestData: request.httpBody,
                                                                               responseData: data,
                                                                               request: request,
                                                                               processor: processor)

                var preparedRequest = request
                preparedRequest.httpBody = prepRequestBodyData

                let stub = RequestStub(request: preparedRequest,
                                       response: response,
                                       responseData: prepResponseBodyData,
                                       error: error)

                self.stubSource.store(stub, options: options)

                completion(data, response, error)
            }
            .resume()
        } else {
         assertionFailure("Only supporting URLSessionDataTask atm.")
        }
    }

    private func prepare(requestData: Data?,
                         responseData: Data?,
                         request: URLRequest,
                         processor: BodyDataProcessor?) ->
        (preparedRequestBodyData: Data?, preparedResponseBodyData: Data?) {

            let prepRequestBodyData, prepResponseBodyData: Data?
            if let bodyDataProcessor = processor {
                prepRequestBodyData = bodyDataProcessor.dataForStoringRequestBody(data: requestData, of: request)
                prepResponseBodyData = bodyDataProcessor.dataForStoringResponseBody(data: responseData, of: request)
            } else {
                prepRequestBodyData = requestData
                prepResponseBodyData = responseData
            }
            return (prepRequestBodyData, prepResponseBodyData)
    }
}
