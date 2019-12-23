//
//  URLRequest+Matcher.swift
//  
//
//  Created by Kim Dung-Pham on 23.12.19.
//

import Foundation

extension URLRequest {

    /// Verifies if this request and matches the other one.
    func matches(otherRequest: URLRequest) -> Bool {
        let sortedA = self.allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        let sortedB = otherRequest.allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        return self.url == otherRequest.url &&
            self.httpMethod == otherRequest.httpMethod &&
            (self.httpBody == otherRequest.httpBody || self.httpBody == nil && otherRequest.httpBody == nil) &&
            sortedA == sortedB
    }
}
