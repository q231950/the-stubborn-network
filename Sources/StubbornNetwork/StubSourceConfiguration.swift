//
//  File.swift
//  
//
//  Created by Martin Kim Dung-Pham on 24.09.19.
//

import Foundation

/// StubSourceConfiguration defines the `URLSessionStub`s’ lifetime. They can either be ephemeral or they can be persisted on disk.
/// When persisting a stub source to disk, the path and name for the source have to be provided.
public enum StubSourceConfiguration {
    case ephemeral
    case persistent(name: String, path: String)
}
