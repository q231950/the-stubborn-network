//
//  StubSourceLocation.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.07.19.
//

import Foundation

/// These keys are used by tests to setup the environment variables of the application under test.
/// The values are read inside the application to identify the location of the current stub during test execution.
public enum EnvironmentVariableKeys: String {
    case stubName = "STUB_NAME"
    case stubPath = "STUB_PATH"
}

/// A _Stub Source Location_ defines where to find a _Stub Source_.
struct StubSourceLocation {
    let stubSourceName: String
    let stubSourcePath: String

    /// Create a _Stub Source Location_ from a _Process Info_.
    ///
    /// This initializer takes a process info in order to read the environment variables
    /// which define the path and name of the current stub source during test execution
    /// - Parameter processInfo: The process info is setup by the test, using the `EnvironmentVariableKeys` to specify
    /// a path and a name of a stub source
    init?(processInfo: ProcessInfo = ProcessInfo()) {
        guard let name = processInfo.environment[EnvironmentVariableKeys.stubName.rawValue],
            let path = processInfo.environment[EnvironmentVariableKeys.stubPath.rawValue] else { return nil }

        self.init(name: name, path: path)
    }

    init(name: String, path: String) {
        stubSourceName = name
        stubSourcePath = path
    }
}
