//
//  EnvironmentTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.09.19.
//

import XCTest
@testable import StubbornNetwork

/**
 A stubbable `ProcessInfo` subclass

 `Environment` expects a `ProcessInfo` to derive information about the name and location of the stub source. The `ProcessInfoStub` subclass of `ProcessInfo` is used to stub values into the otherwise immutable `ProcessInfo` to be able to test for the location and name.
 */
private final class ProcessInfoStub: ProcessInfo {

    let testing: Bool
    let stubName: String?
    let stubPath: String?
    init(testing: Bool = true, stubName: String? = nil, stubPath: String? = nil) {
        self.testing = testing
        self.stubName = stubName
        self.stubPath = stubPath
        super.init()
    }

    override var environment: [String : String] {
        get {
            var pairs: [String:String] = [:]
            if stubName != nil {
                pairs[Keys.stubName.rawValue] = stubName
            }

            if stubPath != nil {
                pairs[Keys.stubPath.rawValue] = stubPath
            }

            if testing {
                pairs[Keys.testing.rawValue] = "testing"
            }

            return pairs
        }
    }
}

class EnvironmentTests: XCTestCase {

    func testInitializesWithProcessInfo() {
        let processInfo = ProcessInfoStub(stubName: "a stub source", stubPath: "127.0.0.1")
        let environment = Environment(processInfo: processInfo)

        XCTAssertTrue(environment.testing)
        XCTAssertEqual(environment.stubSourceName, "a stub source")
        XCTAssertNotNil(environment.stubSourcePath)
    }

    func testInitializesVariables() {
        let environment = Environment(testing: true,
                                      stubSourceName:
            "a name",
                                      stubSourcePath: URL(string:"127.0.0.1")!)
        XCTAssertTrue(environment.testing)
        XCTAssertNotNil(environment.stubSourceName)
        XCTAssertNotNil(environment.stubSourcePath)
    }

    static var allTests = [(
        "testInitializesWithProcessInfo", testInitializesWithProcessInfo),
                           ("testInitializesVariables", testInitializesVariables)]
}
