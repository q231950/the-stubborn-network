//
//  StubRecorder.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.12.19.
//

import Foundation

struct StubRecorder: StubRecording {


    /// The Stub Source dictates how the stub will be stored and where
    let stubSource: StubSourceProtocol

    /// This URL Session  is used to get the actual data, response and error for the URL Session Tasks which are recorded
    let urlSession: URLSession

    init(urlSession: URLSession, stubSource: StubSourceProtocol) {
        self.urlSession = urlSession
        self.stubSource = stubSource
    }

    func record(_ task: URLSessionTask?, bodyDataProcessor: BodyDataProcessor?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let task = task, let request = task.originalRequest else { return }

        if task.self.isKind(of: URLSessionDataTask.self) {
            urlSession.dataTask(with: request) { (data, response, error) in

                let (preparedRequestBodyData, preparedResponseBodyData) = self.prepareBodyData(requestBodyData: request.httpBody,
                                                                                          responseBodyData: data,
                                                                                          request: request,
                                                                                          bodyDataProcessor: bodyDataProcessor)

                var preparedRequest = request
                preparedRequest.httpBody = preparedRequestBodyData

                let stub = RequestStub(request: preparedRequest,
                                       data: preparedResponseBodyData,
                                       response: response,
                                       error: error)

                self.stubSource.store(stub)

                completion(data, response, error)
            }.resume()
        }
    }

    private func prepareBodyData(requestBodyData: Data?, responseBodyData: Data?, request: URLRequest, bodyDataProcessor: BodyDataProcessor?) ->
        (preparedRequestBodyData: Data?, preparedResponseBodyData: Data?) {
            let preparedRequestBodyData, preparedResponseBodyData: Data?
            if let bodyDataProcessor = bodyDataProcessor {
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


}
