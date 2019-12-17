//
//  StubSourceProtocol.swift
//  
//
//  Created by Martin Kim Dung-Pham on 13.10.19.
//

import Foundation

typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

protocol StubSourceProtocol {

    /// Store a stub into the stub source.
    /// - Parameter stub: The stub to store
    func store(_ stub: RequestStub)

    /// Get information about which requests have a stored stub
    /// - Parameter request: The request to check
    func hasStub(_ request: URLRequest) -> Bool

    /// Get a `RequestStub` if one has been previously recorded for the given request
    /// - Parameter request: the request to find and return a stub for
    func stub(forRequest request: URLRequest) -> RequestStub?

    /// Clear the `StubSource`.
    /// This ideally removes all stubs from the `StubSource`
    func clear()

    /// This function loads a stub for the for a given request and returns a `URLSessionTask`
    /// and will execute the closure with the previously stubbed data/response/error
    /// once the data task is resumed.
    /// - Parameter request: The request to find a matching stub for
    /// - Parameter completionHandler: The closure to execute once the data task is resumed
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask
}
