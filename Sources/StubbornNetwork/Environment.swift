//
//  Environment.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.07.19.
//

import Foundation

enum Keys: String {
    case testing = "TESTING"
    case stubName = "STUB_NAME"
    case stubPath = "STUB_PATH"
}

///
/// An environment can be queried for whether or not the app has been launched in a testing environment.
///
/// Application logic can (carefully) take different code paths for testing purposes. For exampe, Xcode UI Tests
/// should not run against the production backend - a testing environment might provide an alternate server
/// for network requests or stubbornly stub requests.
///
public struct Environment {
    public let testing: Bool
    public let stubSourceName: String?
    public let stubSourcePath: URL?

    public init(processInfo: ProcessInfo = ProcessInfo()) {
        let testing = processInfo.environment[Keys.testing.rawValue] != nil
        guard let stubSourceName = processInfo.environment[Keys.stubName.rawValue],
            let stubSourcePath = processInfo.environment[Keys.stubPath.rawValue] else {
                self.init(testing: testing)
                return
        }

        var url = URL(string: stubSourcePath)
        url?.appendPathComponent("com.q231950.StubbornNetworkStubs")
        self.init(testing: testing,
                  stubSourceName: stubSourceName,
                  stubSourcePath: url)
    }

    internal init(testing: Bool, stubSourceName: String? = nil, stubSourcePath: URL? = nil) {
        self.testing = testing
        self.stubSourceName = stubSourceName
        self.stubSourcePath = stubSourcePath
    }

}
