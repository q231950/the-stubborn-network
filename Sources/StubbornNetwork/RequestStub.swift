//
//  RequestStub.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

enum RequestStubCodableError: Error {
    case missingRequestURLError(String)
    case missingResponseURLError(String)
}

struct RequestStub: CustomDebugStringConvertible, Codable {
    let error: Error?
    let request: URLRequest
    let requestData: Data?
    let response: URLResponse?
    let responseData: Data?

    enum CodingKeys: String, CodingKey {
        case error
        case request
        case requestData
        case response
        case responseData
    }

    enum RequestCodingKeys: String, CodingKey {
        case headerFields
        case method
        case requestData
        case url
    }

    enum ResponseCodingKeys: String, CodingKey {
        case headerFields
        case responseData
        case statusCode
        case url
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var requestContainer = container.nestedContainer(keyedBy: RequestCodingKeys.self, forKey: .request)
        try requestContainer.encode(request.url?.absoluteString, forKey: .url)
        let requestHeaderFieldsAsStrings = request.allHTTPHeaderFields?.compactMap({ (key, value) in
            "\(key)[:::]\(value)"
        })
        try requestContainer.encode(requestHeaderFieldsAsStrings, forKey: .headerFields)
        try requestContainer.encode(request.httpMethod, forKey: .method)
        try requestContainer.encode(request.httpBody, forKey: .requestData)
        
        try container.encode(requestData, forKey: .requestData)
        
        var responseContainer = container.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .response)
        if let response = response as? HTTPURLResponse {
            if let responseUrl = response.url?.absoluteString {
                try responseContainer.encode(responseUrl, forKey: .url)
            }
            try responseContainer.encode(response.statusCode, forKey: .statusCode)
            try responseContainer.encode(response.allHeaderFields.map({ (key, value) in "\(key)[:::]\(value)"}),
                                         forKey: .headerFields)
        }
        try responseContainer.encode(responseData, forKey: .responseData)
    }

    init(request: URLRequest, requestData: Data? = nil, response: URLResponse? = nil, responseData: Data? = nil, error: Error? = nil) {
        self.request = request
        self.requestData = requestData
        self.response = response
        self.responseData = responseData
        self.error = error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let requestContainer = try container.nestedContainer(keyedBy: RequestCodingKeys.self, forKey: .request)
        let requestUrl = try requestContainer.decode(String.self, forKey: .url)
        guard let decodedURL = URL(string: requestUrl) else {
            throw RequestStubCodableError.missingRequestURLError("Unable to decode URL")
        }
        var request = URLRequest(url: decodedURL)
        request.httpMethod = try requestContainer.decode(String.self, forKey: .method)
        
        let headers = try requestContainer.decode([String].self, forKey: .headerFields)
        request.allHTTPHeaderFields = RequestStub.httpHeaders(from: headers)
        let requestBodyData = try requestContainer.decode(Data?.self, forKey: .requestData)
        request.httpBody = requestBodyData

        // Response
        let responseContainer = try container.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .response)
        let responseBodyData = try responseContainer.decode(Data.self, forKey: .responseData)
        let responseUrlString = try responseContainer.decode(String.self, forKey: .url)
        let resHeaders = try responseContainer.decode([String].self, forKey: .headerFields)
        let responseHeaders = RequestStub.httpHeaders(from: resHeaders)
        let responseStatusCode = try responseContainer.decode(Int.self, forKey: .statusCode)

        guard let responseUrl = URL(string: responseUrlString) else {
            throw RequestStubCodableError.missingResponseURLError(responseUrlString)
        }

        let response = HTTPURLResponse(url: responseUrl,
                                       statusCode: responseStatusCode,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: responseHeaders)
        
        self.init(request: request, requestData: requestBodyData, response: response, responseData: responseBodyData)
    }

    var debugDescription: String {
        let requestDescription = String(describing: request.debugDescription)
        let dataDescription = String(describing: requestData?.count)
        return "[RequestStub] \(requestDescription) \(dataDescription) \(response.debugDescription)"
    }

    static func httpHeaders(from headers: [String]) -> [String:String] {
        let httpHeaders = headers.reduce(into: [String: String]()) { (result, field) in
            let keyValue = field.components(separatedBy: "[:::]")
            if let key = keyValue.first, let value = keyValue.last {
                result[key] = value
            }
        }

        return httpHeaders
    }
}

extension RequestStub: Equatable {
    static func == (lhs: RequestStub, rhs: RequestStub) -> Bool {
        return lhs.requestData == rhs.requestData &&
            lhs.request.matches(otherRequest: rhs.request) &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
            lhs.response == rhs.response
    }
}
