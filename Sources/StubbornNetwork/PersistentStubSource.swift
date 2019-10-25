//
//  StubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

struct PersistentStubSource: StubSourceProtocol {
    let path: URL
    var stubs = [RequestStub]()

    init(path: URL) {
        self.path = path

        if let data = try? stubRecordData() {
            setupStubs(from: data)
        }
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        let requestStub = stub(forRequest: request)
        precondition(requestStub != nil, "\(request.preconditionFailureDescription) - Path: \(path.absoluteString)")
        return URLSessionDataTaskStub(data: requestStub?.data,
                                      response: requestStub?.response,
                                      error: requestStub?.error,
                                      resumeCompletion: completionHandler)
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
        let url = URL(fileURLWithPath: path.absoluteString, isDirectory: false)
        return try Data(contentsOf: url)
    }

    func stub(forRequest request: URLRequest) -> RequestStub? {
        print("Loading stub for request \(request.url?.absoluteString ?? "unknown")")
        return stubs.first(where: request.matches(requestStub:))
    }

    mutating func store(_ stub: RequestStub) {
        print("Storing stub: \(stub) at \(path.absoluteString).")

        stubs.append(stub)

        do {
            let encoder = JSONEncoder()
            let json = try encoder.encode(stubs)
            let fileManager = FileManager.default
            fileManager.createFile(atPath: path.absoluteString,
                                   contents: json,
                                   attributes: [FileAttributeKey.type: "json"])
        } catch {
            print("\(error)")
        }
    }
}

extension URLRequest {
    var preconditionFailureDescription: String {
        "Unable to find a request stub for the given request: \(url?.absoluteString ?? "")."
    }
}

extension PersistentStubSource {
    init(name: String, path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.absoluteString) {
            PersistentStubSource.createStubDirectory(at: path)
        }

        var sanitizedName = name.replacingOccurrences(of: " ", with: "_")
        sanitizedName = sanitizedName.replacingOccurrences(of: "[", with: "")
        sanitizedName = sanitizedName.replacingOccurrences(of: "]", with: "")
        sanitizedName = sanitizedName.replacingOccurrences(of: "-", with: "")
        let url = path.appendingPathComponent("\(sanitizedName).json")

        self.init(path: url)
    }

    static func createStubDirectory(at path: URL) {
        do {
            try FileManager.default.createDirectory(atPath: path.absoluteString, withIntermediateDirectories: true)
        } catch let error {
            assertionFailure("Unable to create stub directory. \(error.localizedDescription)")
        }
    }
}

extension URLRequest {
    func matches(requestStub: RequestStub) -> Bool {
        return matches(request: requestStub.request)
    }

    func matches(request other: URLRequest) -> Bool {
        let sortedA = self.allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        let sortedB = other.allHTTPHeaderFields?.map({ (key, value) -> String in
            return key.lowercased() + value
        }).sorted(by: <)

        return self.url == other.url &&
            self.httpMethod == other.httpMethod &&
            sortedA == sortedB
    }
}
