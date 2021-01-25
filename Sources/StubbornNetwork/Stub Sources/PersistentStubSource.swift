//
//  PersistentStubSource.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.07.19.
//

import Foundation

class PersistentStubSource: StubSourceProtocol {

    let path: URL
    var stubs = [RequestStub]()
    var cachedResponses = [CachedResponse]()
    var recordMode = false

    convenience init(with location: StubSourceLocation) {
        guard let url = URL(string: location.stubSourcePath) else {
            preconditionFailure(
                """
                The path to the stub source is not a valid path.
                Choose a valid path in the stub source configuration.
                """)
        }

        self.init(name: location.stubSourceName, path: url)
    }

    init(path: URL) {
        self.path = path

        if let data = try? stubRecordData() {
            setupStubs(from: data)
        } else {
            recordMode = true
        }
    }

    func setupStubs(from data: Data) {
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

    func stub(forRequest request: URLRequest, options: RequestMatcherOptions) -> RequestStub? {
        guard !recordMode else { return nil }

        let stub = stubs.first { request.matches($0.request, options: options) }
        if let index = stubs.firstIndex(where: { request.matches($0.request, options: options) }) {
            stubs.remove(at: index)
        }

        if stub != nil {
            print("Found stub for: \(request.url?.absoluteString ?? "")")
        } else {
            print("Did not find stub for: \(request.url?.absoluteString ?? "")")
        }

        return stub
    }

    func store(_ stub: RequestStub, options: RequestMatcherOptions) {
        guard recordMode else {
            print("Won't record when not in record mode")
            return
        }

        print("Storing stub: \(stub.request.url?.absoluteString ?? "") (\(stub.request.httpBody?.count ?? 0)) at \(path.absoluteString).")

        addAndSave(stub)
    }

    func clear() {
        stubs.removeAll()

        save(stubs)
    }

    private func addAndSave(_ stub: RequestStub) {
        stubs.append(stub)

        save(stubs)
    }

    func save(_ stubs: [RequestStub]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let json = try encoder.encode(stubs)
            let fileManager = FileManager.default
            fileManager.createFile(atPath: path.absoluteString,
                                   contents: json,
                                   attributes: [FileAttributeKey.type: "json"])
        } catch {
            assertionFailure("\(error)")
        }
    }

    func hasStub(_ request: URLRequest, options: RequestMatcherOptions) -> Bool {
        let stub = stubs.first { request.matches($0.request, options: options) }
        return stub != nil
    }
}

extension PersistentStubSource {

    /// Initialize a _Persistent Stub Source_ with a name and a path.
    ///
    /// - Parameters:
    ///   - name: this is how the _Stub Source_ is called
    ///   - path: the location of the _Stub Source_
    convenience init(name: String, path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.absoluteString) {
            print("File does not exist at path: \(path.absoluteString)")
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
