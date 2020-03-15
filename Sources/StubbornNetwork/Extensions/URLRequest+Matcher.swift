//
//  URLRequest+Matcher.swift
//  
//
//  Created by Kim Dung-Pham on 23.12.19.
//

import Foundation

extension URLRequest {

    /// Matches this request against the other one.
    ///
    /// The matching criteria are:
    /// - url matches
    /// - headers match
    /// - http method matches
    /// - http body matches
    /// - Parameters:
    ///   - otherRequest: The request to match against
    ///   - options: These options define what should be taken into consideration for matching the requests
    func matches(otherRequest: URLRequest, options: RequestMatcherOptions? = .strict) -> Bool {
        guard let options = options else { return false }

        if options.contains(.url) && url != otherRequest.url {
            return false
        }

        if options.contains(.headers) {
            let sortedA = allHTTPHeaderFields?.map({ (key, value) -> String in
                return key.lowercased() + value
            }).sorted(by: <)

            let sortedB = otherRequest.allHTTPHeaderFields?.map({ (key, value) -> String in
                return key.lowercased() + value
            }).sorted(by: <)

            if (sortedA != sortedB) &&
                !((sortedB?.count == 0 && sortedA == nil) || (sortedA?.count == 0 && sortedB == nil)) {
                return false
            }
        }

        if options.contains(.httpMethod) && httpMethod != otherRequest.httpMethod {
            return false
        }

        if options.contains(.body) {
            if httpBody != otherRequest.httpBody && httpBody != nil && otherRequest.httpBody != nil {
                return false
            }
        }

        return true
    }
}
