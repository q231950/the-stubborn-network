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
    // possibly remove matcher and options here
    func store(_ stub: RequestStub, options: RequestMatcherOptions)

    /// Get information about which requests have a stored stub
    /// - Parameter request: The request to check the availability of a stub for
    func hasStub(_ request: URLRequest, options: RequestMatcherOptions) -> Bool

    /// Get a `RequestStub` if one has been previously recorded for the given request
    /// - Parameter request: the request to find and return a stub for
    func stub(forRequest request: URLRequest, options: RequestMatcherOptions) -> RequestStub?

    /// Clear the _Stub Source_. This ideally removes all stubs from the _Stub Source_.
    func clear()
}
