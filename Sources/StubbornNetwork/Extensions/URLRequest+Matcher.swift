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
    func matches(otherRequest: URLRequest) -> Bool {
        let sortedA = allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        let sortedB = otherRequest.allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        let headersMatch = sortedA == sortedB
        let urlMatches = url == otherRequest.url
        let httpMethodMatches = httpMethod == otherRequest.httpMethod
        let httpBodyMatches = (httpBody == otherRequest.httpBody ||
            httpBody == nil && otherRequest.httpBody == nil)

        return urlMatches &&
            headersMatch &&
            httpMethodMatches &&
        httpBodyMatches
    }
}
