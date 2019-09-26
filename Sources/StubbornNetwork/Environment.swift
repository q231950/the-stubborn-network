//
//  Environment.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.07.19.
//

import Foundation

/// These keys are used by tests to setup the environment variables of the application under test.
/// The values are read inside the application to identify the location of the current stub during test execution.
enum EnvironmentVariableKeys: String {
    case stubName = "STUB_NAME"
    case stubPath = "STUB_PATH"
}

/// An environment defines the location of a `StubSource`.
struct Environment {
    let stubSourceName: String?
    let stubSourcePath: String?

    /// The initializer takes a process info in order to read the environment variables
    /// which define the location o the current stub source during test execution
    /// - Parameter processInfo: The process info is setup by the test, using the `EnvironmentVariableKeys` to specify a path and a name of a stub source
    init(processInfo: ProcessInfo = ProcessInfo()) {
        let stubSourceName = processInfo.environment[EnvironmentVariableKeys.stubName.rawValue]
        let stubSourcePath = processInfo.environment[EnvironmentVariableKeys.stubPath.rawValue]

        self.init(stubSourceName: stubSourceName,
                  stubSourcePath: stubSourcePath)
    }

    private init(stubSourceName: String? = nil, stubSourcePath: String? = nil) {
        self.stubSourceName = stubSourceName
        self.stubSourcePath = stubSourcePath
    }

}
