//
//  BodyDataProcessorProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 20.10.19.
//

import Foundation

public protocol BodyDataProcessor {

    /// This function allows to modify a request's body data before it gets written into a stub.
    ///
    /// The function is called before the stub for the given request is stored. If the data of the given request should not be modified, the original `data`
    ///  can be returned.
    /// - Parameter data: The unmodified data of the request body
    /// - Parameter request: The request that will be stubbed
    func prepareRequestBodyForStorage(data: Data?, of request: URLRequest) -> Data?

    /// This function allows to modify a response's body data before it gets written into a stub.
    ///
    /// The function is called just before the data will be stored in a stub for the given request.
    /// - Parameter data: The unmodified data of the response body
    /// - Parameter request: The request that led to the response
    func prepareResponseBodyForStorage(data: Data?, of request: URLRequest) -> Data?

    /// This function allows to modify a stub's response body data just before the stub will be delivered.
    /// - Parameter data: The stubbed response body data as it was when the stub was stored
    /// - Parameter request: The request that led to the original response body
    func processResponseBodyForDelivery (data: Data?, of request: URLRequest) -> Data?
}
