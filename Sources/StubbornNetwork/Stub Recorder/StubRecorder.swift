//
//  StubRecorder.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.12.19.
//

import Foundation

/// The Stub Recorder records stubs by making an actual request and storing the response in a Stub Source.
struct StubRecorder: StubRecording {

    /// The _Stub Source_ dictates how the stub will be stored and where
    let stubSource: StubSourceProtocol

    /// This `URLSession` is used to get the actual data, response and error
    /// for the `URLSessionTask`s which are recorded.
    let urlSession: URLSession

    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                options: RequestMatcherOptions?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        guard let task = task, let request = task.originalRequest else { return }

        if task.self.isKind(of: URLSessionDataTask.self) {
            urlSession.dataTask(with: request) { (data, response, error) in

                let (prepRequestBodyData, prepResponseBodyData) = self.prepare(requestData: request.httpBody,
                                                                               responseData: data,
                                                                               request: request,
                                                                               processor: processor)

                var preparedRequest = request
                preparedRequest.httpBody = prepRequestBodyData

                let stub = RequestStub(request: preparedRequest,
                                       data: prepResponseBodyData,
                                       response: response,
                                       error: error)

                self.stubSource.store(stub, options: options)

                completion(data, response, error)
            }.resume()
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
