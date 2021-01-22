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
    func matches(_ otherRequest: URLRequest, options: RequestMatcherOptions = .strict) -> Bool {

        let customMatches: [Bool] = options.customMatchers.map({ matcher in
            if case .custom(let match) = matcher {
                return match(self, otherRequest)
            }
            return false
        })

        guard !customMatches.contains(true) else { return true }

        let nonCustomMatches: [Bool] = options.nonCustomMatchers.map { matcher in
            switch matcher {
            case .headers:
                return headersMatch(otherRequest)
            case .httpMethod:
                return httpMethodMatches(otherRequest)
            case .requestBody:
                return requestBodyMatches(otherRequest)
            case .url:
                return urlMatches(otherRequest)
            case .custom:
                return true
            }
        }

        return !nonCustomMatches.contains(false)
    }

    private func urlMatches(_ otherRequest: URLRequest) -> Bool {

        guard let url = url?.absoluteString, let otherURL = otherRequest.url?.absoluteString else { return false }

        let components = URLComponents(string: url)
        let queryItems = components?.queryItems?.sorted { (a: URLQueryItem, b: URLQueryItem) in
            a.name < b.name || (a == b && a.value ?? "" < b.value ?? "")
        }

        let otherComponents = URLComponents(string: otherURL)
        let otherQueryItems = otherComponents?.queryItems?.sorted { (a: URLQueryItem, b: URLQueryItem) in
            a.name < b.name || (a == b && a.value ?? "" < b.value ?? "")
        }

        return components?.path == otherComponents?.path && queryItems == otherQueryItems
    }

    private func requestBodyMatches(_ otherRequest: URLRequest) -> Bool {
        httpBody == otherRequest.httpBody || httpBody == nil && otherRequest.httpBody == nil
    }

    private func httpMethodMatches(_ otherRequest: URLRequest) -> Bool {
        httpMethod == otherRequest.httpMethod
    }

    private func headersMatch(_ otherRequest: URLRequest) -> Bool {
        let sortedA = allHTTPHeaderFields?.map { key, value -> String in
            return key.lowercased() + value
        }
        .sorted(by: <)

        let sortedB = otherRequest.allHTTPHeaderFields?.map { key, value -> String in
            return key.lowercased() + value
        }
        .sorted(by: <)

        if (sortedA != sortedB) &&
            !((sortedB?.isEmpty ?? true && sortedA == nil) || (sortedA?.isEmpty ?? true && sortedB == nil)) {
            return false
        }

        return true
    }
}
