//
//  StubRecorderProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.12.19.
//

import Foundation

protocol StubRecording {

    /// Record the response of a task into a stub.
    ///
    /// - Parameters:
    ///   - task: the task to record a stub for.
    ///   - processor: When this optional processor is given, the stubbed data will be passed to it prior to storing it.
    ///                        This allows to alter the request and response data of the stub. It is useful when sensitive
    ///                        information should not end up in the stubs.
    ///   - options: The options how client requests and stubs should be matched. If only the url of a request is
    ///              sufficient to determine the correct stubbed request, then `.url` might be passed and one would not
    ///              need to bother making the stubbed request's header and body exactly fit to the expected client
    ///              request.
    ///   - completion: the completion is called with the unaltered response from performing the task's
    ///                 request on a `URLSession`.
    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                options: RequestMatcherOptions,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}
