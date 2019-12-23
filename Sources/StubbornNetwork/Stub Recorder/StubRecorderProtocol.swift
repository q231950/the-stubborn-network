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
    ///   - task: the task to record a stub for
    ///   - processor: When this optional processor is given, the stubbed data will be passed to it prior to storing it.
    ///                        This allows to alter the request and response data of the stub. It is useful when sensitive
    ///                        information should not end up in the stubs.
    ///   - completion: the completion is called with the unaltered response from performing the task's request on a `URLSession`
    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void)

}
