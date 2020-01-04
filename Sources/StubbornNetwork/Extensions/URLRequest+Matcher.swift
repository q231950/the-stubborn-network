//
//  URLRequest+Matcher.swift
//  
//
//  Created by Kim Dung-Pham on 23.12.19.
//

import Foundation

extension URLRequest {

    /// Verifies if this request and matches the other one.
    func matches(otherRequest: URLRequest, options: RequestMatcherOptions? = .lenient) -> Bool {
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

            if sortedA != sortedB {
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
