//
//  ProcessInfo+Testing.swift
//
//
//  Created by Martin Kim Dung-Pham on 19.10.19.
//

import Foundation

public extension ProcessInfo {
    /// Returns `true` if the `ProcessInfo` contains a `THE_STUBBORN_NETWORK_UI_TESTING` environment variable.
    public var isUITesting: Bool {
        get {
            return environment["THE_STUBBORN_NETWORK_UI_TESTING"] != nil
        }
    }
}
