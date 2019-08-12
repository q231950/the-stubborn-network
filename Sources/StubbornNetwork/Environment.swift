//
//  Environment.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.07.19.
//

import Foundation

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

    init(testing: Bool, stubSourceName: String? = nil, stubSourcePath: URL? = nil) {
        self.testing = testing
        self.stubSourceName = stubSourceName
        self.stubSourcePath = stubSourcePath
    }

    public static var current: Environment? {
        get {
            let p = ProcessInfo()

            let testing = p.environment["TESTING"] != nil
            guard let stubSourceName = p.environment["STUB_NAME"],
                let stubSourcePath = p.environment["STUB_PATH"] else {
                    return Environment(testing: testing)
            }

            var url = URL(string: stubSourcePath)
            url?.appendPathComponent("com.q23.StubbornNetworkStubs")
            return Environment(testing: testing,
                               stubSourceName: stubSourceName,
                               stubSourcePath: url)
        }
    }
}
