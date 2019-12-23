//
//  RequestStub.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

enum RequestStubCodableError: Error {
    case missingRequestURLError(String)
}

struct RequestStub: CustomDebugStringConvertible, Codable {
    let request: URLRequest
    let data: Data?
    let response: URLResponse?
    let error: Error?

    enum CodingKeys: String, CodingKey {
        case request
        case data
        case response
        case error
    }

    enum RequestCodingKeys: String, CodingKey {
        case url
        case method
        case headerFields
        case requestData
    }

    enum ResponseCodingKeys: String, CodingKey {
        case statusCode
        case headerFields
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

        try container.encode(data, forKey: .data)

        var responseContainer = container.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .response)
        if let response = response as? HTTPURLResponse {
            try responseContainer.encode(response.statusCode, forKey: .statusCode)
            try responseContainer.encode(response.allHeaderFields.map({ (key, value) in "\(key)[:::]\(value)"}),
                                         forKey: .headerFields)
        }
    }

    init(request: URLRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.request = request
        self.data = data
        self.response = response
        self.error = error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let requestContainer = try container.nestedContainer(keyedBy: RequestCodingKeys.self, forKey: .request)
        let url = try requestContainer.decode(String.self, forKey: .url)
        guard let decodedURL = URL(string: url) else {
            throw RequestStubCodableError.missingRequestURLError("Unable to decode URL")
        }
        var request = URLRequest(url: decodedURL)
        request.httpMethod = try requestContainer.decode(String.self, forKey: .method)

        let headers = try requestContainer.decode([String].self, forKey: .headerFields)
        request.allHTTPHeaderFields = headers.reduce(into: [String: String]()) { (result, field) in
            let keyValue = field.components(separatedBy: "[:::]")
            if let key = keyValue.first, let value = keyValue.last {
                result[key] = value
            }
        }
        let requestBodyData = try requestContainer.decode(Data?.self, forKey: .requestData)
        request.httpBody = requestBodyData

        let data = try container.decode(Data.self, forKey: .data)

        self.init(request: request, data: data)
    }

    var debugDescription: String {
        let requestDescription = String(describing: request.debugDescription)
        let dataDescription = String(describing: data?.count)
        return "[RequestStub] \(requestDescription) \(dataDescription) \(response.debugDescription)"
    }
}

extension RequestStub: Equatable {
    static func == (lhs: RequestStub, rhs: RequestStub) -> Bool {
        return lhs.data == rhs.data &&
        lhs.request.matches(otherRequest: rhs.request) &&
            lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
            lhs.response == rhs.response
    }
}
