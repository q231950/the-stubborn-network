//
//  TestHelper.swift
//  
//
//  Created by Martin Kim Dung-Pham on 20.11.19.
//

import Foundation

struct TestHelper {

    /// returns the path to the stubs to use during testing
    static func testingStubSourcePath() -> String {
        testingStubSourceUrl().absoluteString
    }

    /// returns the file url to the stubs to use during testing
    static func testingStubSourceUrl() -> URL {
        let testProcessInfo = ProcessInfo()
        let exportedDirectoryPath = testProcessInfo.environment["TRAVIS_BUILD_DIR"] ?? testProcessInfo.environment["STUB_DIR"]
        let stubDirectoryPath: String?
        if let path = exportedDirectoryPath {
            stubDirectoryPath = path
        } else {
            stubDirectoryPath = testProcessInfo.environment["XCTestConfigurationFilePath"]
        }
        assert(stubDirectoryPath != nil,
               """
               Incorrect Test Setup ⚠️
               \t... Please export either a TRAVIS_BUILD_DIR or a STUB_DIR to store the stubs during test execution.
               \t... what about giving `export STUB_DIR='./stubs' && swift test` a try?\n
               """)
        let url = URL(string: stubDirectoryPath!)
        assert(url != nil,
        """
        Incorrect Test Setup ⚠️
        \t... The path to the testing stubs you provided (\(stubDirectoryPath!)) is not valid.
        """)

        return url!
    }
}
