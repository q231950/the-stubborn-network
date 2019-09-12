//
//  StubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

public protocol StubSourceProtocol {

    init(url: URL)

    mutating func store(_ stub: RequestStub)

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

struct PersistentStubSource: StubSourceProtocol {
    let url: URL
    var stubs = [RequestStub]()

    init(url: URL) {
        self.url = url

        if let data = try? stubRecordData() {
            setupStubs(from: data)
        }
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let s = stub(forRequest: request)
        precondition(s != nil, "Unable to find a request stub for the given request: \(request.url?.absoluteString ?? "") in stub source at \(url.absoluteString).")
        return URLSessionDataTaskStub(request: request, data: s?.data, response: s?.response, error:s?.error, resumeCompletion: completionHandler)
    }

    mutating func setupStubs(from data: Data) {
        do {
            let decoder = JSONDecoder()
            let prerecordedStubs = try decoder.decode([RequestStub].self, from: data)
            stubs.append(contentsOf: prerecordedStubs)
        } catch {
            print("Failed to set up stubs with error: \(error)")
        }
    }

    private func stubRecordData() throws -> Data {
        let u = URL(fileURLWithPath: url.absoluteString, isDirectory: false)
        return try Data(contentsOf: u)
    }

    func stub(forRequest request: URLRequest) -> RequestStub? {
        print("Loading stub for request \(request.url?.absoluteString ?? "unknown")")
        return stubs.filter(request.matches()).first
    }

    mutating func store(_ stub: RequestStub) {
        print("Storing stub: \(stub) at \(url.absoluteString).")

        stubs.append(stub)

        do {
            let encoder = JSONEncoder()
            let json = try encoder.encode(stubs)
            let fileManager = FileManager.default
            fileManager.createFile(atPath: url.absoluteString, contents: json, attributes: [FileAttributeKey.type: "json"])
        } catch {
            print("\(error)")
        }
    }
}

extension URLRequest {
    func matches() -> ((RequestStub) -> Bool) {
        let closure = { (requestStub: RequestStub) -> Bool in
            let sortedA = self.allHTTPHeaderFields?.map({ (key, value) -> String in
                return key + value
            }).sorted(by: { (a, b) -> Bool in
                return a < b
            })

            let sortedB = requestStub.request.allHTTPHeaderFields?.map({ (key, value) -> String in
                return key + value
            }).sorted(by: { (a, b) -> Bool in
                return a < b
            })

            return self.url == requestStub.request.url &&
                self.httpMethod == requestStub.request.httpMethod &&
                sortedA == sortedB
        }
        return closure
    }
}
