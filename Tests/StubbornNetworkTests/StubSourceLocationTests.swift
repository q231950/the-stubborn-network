//
//  EnvironmentTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

/// A stubbable `ProcessInfo` subclass
///
/// `StubSourceLocation` expects a `ProcessInfo` to derive information about the name and location of the stub source.
/// The `ProcessInfoStub` subclass of `ProcessInfo` is used to stub values into the otherwise immutable `ProcessInfo`
/// to be able to test for the location and name.
final class ProcessInfoStub: ProcessInfo {

    let stubName: String?
    let stubPath: String?
    init(stubName: String? = nil, stubPath: String? = nil) {
        self.stubName = stubName
        self.stubPath = stubPath
        super.init()
    }

    override var environment: [String : String] {
        get {
            var pairs: [String:String] = [:]
            if stubName != nil {
                pairs[EnvironmentVariableKeys.stubName.rawValue] = stubName
            }

            if stubPath != nil {
                pairs[EnvironmentVariableKeys.stubPath.rawValue] = stubPath
            }
            return pairs
        }
    }
}

class StubSourceLocationTests: XCTestCase {

    func testInitializesWithProcessInfo() {
        let processInfo = ProcessInfoStub(stubName: "a stub source", stubPath: "127.0.0.1")
        let stubSourceLocation = StubSourceLocation(processInfo: processInfo)

        XCTAssertEqual(stubSourceLocation.stubSourceName, "a stub source")
        XCTAssertNotNil(stubSourceLocation.stubSourcePath)
    }

    static var allTests = [(
        "testInitializesWithProcessInfo", testInitializesWithProcessInfo),
    ]
}
