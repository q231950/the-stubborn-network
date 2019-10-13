//
//  StubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

protocol StubSourceProtocol {

    mutating func store(_ stub: RequestStub)
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask
}

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
        return URLSessionDataTaskStub(request: request,
                                      data: requestStub?.data,
                                      response: requestStub?.response,
                                      error:requestStub?.error,
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
        return stubs.filter(request.matches()).first
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
            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: path.absoluteString, withIntermediateDirectories: true)
        }
        catch let error {
            print("\(path.absoluteURL)")
            assertionFailure("Unable to create stub directory. \(error.localizedDescription)")
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
