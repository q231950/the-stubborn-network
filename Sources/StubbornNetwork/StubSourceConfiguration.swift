//
//  StubSourceConfiguration.swift
//  
//
//  Created by Martin Kim Dung-Pham on 24.09.19.
//

import Foundation

/// StubSourceConfiguration defines the `URLSessionStub`s’ lifetime. They can either be ephemeral or they can be persisted on disk.
/// When persisting a stub source to disk the location for the source needs to be provided.
public enum StubSourceConfiguration {
    case ephemeral
    case persistent(location: StubSourceLocation)
}
