//
//  URLSessionStub.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.07.19.
//

import Foundation

enum NetworkStubError: Error {
    case unexpectedRequest(String)
}

public enum RecordMode {
    case recording
    case playback
}

class URLSessionStub: URLSession, StubbornURLSession {
    var stubSource: StubSourceProtocol?
    var recordMode: RecordMode = .playback
    private let endToEndURLSession: URLSession

    init(configuration: URLSessionConfiguration, stubSource: StubSourceProtocol = EphemeralStubSource(), endToEndURLSession: URLSession? = nil) {
        self.endToEndURLSession = endToEndURLSession ?? URLSession(configuration: configuration)
        self.stubSource = stubSource
    }

    func stub(_ request: URLRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let stub = RequestStub(request: request, data: data, response: response, error: error)
        stubSource?.store(stub)
    }

    func setupStubSource(name: String, path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.absoluteString) {
            createStubDirectory(at: path)
        }

        var sanitizedName = name.replacingOccurrences(of: " ", with: "_")
        sanitizedName = sanitizedName.replacingOccurrences(of: "[", with: "")
        sanitizedName = sanitizedName.replacingOccurrences(of: "]", with: "")
        sanitizedName = sanitizedName.replacingOccurrences(of: "-", with: "")
        let url = path.appendingPathComponent("\(sanitizedName).json")
        stubSource = StubSource(url: url)
    }

    private func createStubDirectory(at path: URL) {
        do {
            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: path.absoluteString, withIntermediateDirectories: true)
        }
        catch let e {
            print("\(path.absoluteURL)")
            assertionFailure("Unable to create stub directory. \(e.localizedDescription)")
        }
    }
}


extension URLSessionStub {
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        switch recordMode {
        case .recording:
            assert(stubSource != nil)
            return endToEndURLSession.dataTask(with: request, completionHandler: { (data, response, error) in
                let stub = RequestStub(request: request, data:data, response:response, error:error)
                self.stubSource?.store(stub)
                completionHandler(data, response, error)
            })
        case .playback:
            assert(stubSource != nil)
            return stubSource!.dataTask(with: request, completionHandler: completionHandler)
        }
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return dataTask(with: request, completionHandler: completionHandler)
    }
}
