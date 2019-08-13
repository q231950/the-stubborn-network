//
//  URLSessionStub.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.07.19.
//

import Foundation

public protocol StubbornURLSession: URLSession {


    /**
     Stub a single request. When the session is asked for a `URLSession` task of a similar request, the task will complete with the prerecorded response, error and data.

     - Parameters:
         - request: The request to stub
         - data: The data to return when the request is fulfilled
         - response: The response when the request is fulfilled
         - error: A potential error when the request is fulfilled
    */
    func stub(_ request: URLRequest, data: Data?, response: URLResponse?, error: Error?)

    /**
     The record mode defines the way the StubbornURLSession behaves. It can record or playback stubs.
     */
    var recordMode: RecordMode {get set}

    /**
     Stub a potentially big series of requests with a prerecorded StubSource at the given path.

     - Parameters:
        - name: The name the `StubSource` should carry
        - path: The path to the StubSource
     */
    func setupStubSource(name: String, path: URL)
}

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

    init(configuration: URLSessionConfiguration, stubSource: StubSourceProtocol = EphemeralStubSource()) {
        endToEndURLSession = URLSession(configuration: configuration)
        self.stubSource = stubSource
    }

    /// TODO: implement delegate calls
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?, mode: RecordMode = .playback) {
        endToEndURLSession = URLSession(configuration: .ephemeral)
        recordMode = mode
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
