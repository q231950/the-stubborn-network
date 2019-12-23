//
//  StubSourceProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 13.10.19.
//

import Foundation

typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

/// This protocol defines the abilities of a _Stub Source_. _Stub Sources_ are used to store stubs.
/// It is up to the _Stub Source_ to decide where to store its stubs.
protocol StubSourceProtocol {

    /// Store a stub into the _Stub Source_.
    /// - Parameter stub: The stub to store
    func store(_ stub: RequestStub)

    /// Get information about which requests have a stored stub
    /// - Parameter request: The request to check the availability of a stub for
    func hasStub(_ request: URLRequest) -> Bool

    /// Get a `RequestStub` if one has been previously recorded for the given request
    /// - Parameter request: the request to find and return a stub for
    func stub(forRequest request: URLRequest) -> RequestStub?

    /// Clear the _Stub Source_. This ideally removes all stubs from the _Stub Source_.
    func clear()

    // TODO: Remove this declaration from the protocol and cleanup the implementations as well
    /// This function loads a stub for the for a given request and returns a `URLSessionTask`
    /// and will execute the closure with the previously stubbed data/response/error
    /// once the data task is resumed.
    /// - Parameter request: The request to find a matching stub for
    /// - Parameter completionHandler: The closure to execute once the data task is resumed
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask
}
