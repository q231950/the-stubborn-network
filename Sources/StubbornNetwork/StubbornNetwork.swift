import Foundation

///
/// The Stubborn Network - a Swifty and Clean Stubbing Machine.
///
/// The StubbornNetwork provides stubbed `URLSession`s. These `StubbornURLSession`s
/// can be used during tests to inject stubbed responses into your data structures where normally a
/// `URLSession` would be used to make network requests.
///
/// Stubbing your network can greatly improve flakiness in UI tests and is a common practice
/// for unit tests. You can also use The Stubborn Network for running SwiftUI Previews
/// more efficiently where the stubs act like a cache.
public struct StubbornNetwork {}

// MARK: Ephemeral stubbed URLSessions

extension StubbornNetwork {

    /// Make a stubbed `URLSession` that is ephemeral.
    ///
    /// The stubs of this `StubbornURLSession` are not persisted anywhere. This factory method is useful in unit tests.
    public static func makeEphemeralSession() -> StubbornURLSession {
        return stubbed(withConfiguration: .ephemeral)
    }
}

// MARK: Persistent stubbed URLSessions

extension StubbornNetwork {

    /// Make a stubbed `URLSession` by providing a `ProcessInfo`.
    ///
    /// The `ProcessInfo` contains information about the location of the source for the stubs.
    ///
    /// - Parameter processInfo: The process info that contains `EnvironmentVariableKeys` specifying
    /// the location of the stub source.
    public static func makePersistentSession(withProcessInfo processInfo: ProcessInfo = ProcessInfo())
        -> StubbornURLSession {
        let location = StubSourceLocation(processInfo: processInfo)
        return stubbed(withConfiguration: .persistent(location: location))
    }

    /// Make a stubbed `URLSession` by providing a name and a path to the source for the stubs to use.
    ///
    /// - Parameter name: The file name of the `StubSource`
    /// - Parameter path: The path to the `StubSource`
    public static func makePersistentSession(withName name: String,
                                             path: String)
        -> StubbornURLSession {
        let location = StubSourceLocation(name: name, path: path)
        return stubbed(withConfiguration: .persistent(location: location))
    }
}

// MARK: Module Internal Implementation Details

extension StubbornNetwork {

    static func persistentStubSource(withProcessInfo processInfo: ProcessInfo = ProcessInfo()) -> StubSourceProtocol {
        let location = StubSourceLocation(processInfo: processInfo)
        return persistentStubSource(at: location)
    }

    /// Make a stubbed `URLSession` with a `StubSourceConfiguration`.
    ///
    /// - Parameter configuration: The configuration of the stub source of the stubbed `URLSession`
    static func stubbed(withConfiguration configuration: StubSourceConfiguration = .ephemeral)
        -> StubbornURLSession {

        switch configuration {
        case .ephemeral:
            return URLSessionStub(configuration: .ephemeral, stubSource: EphemeralStubSource())
        case .persistent(let location):
            let stubSource = persistentStubSource(at: location)
            return URLSessionStub(configuration: .ephemeral, stubSource: stubSource)
        }
    }

    static func persistentStubSource(at location: StubSourceLocation) -> StubSourceProtocol {
        let name = location.stubSourceName
        let path = location.stubSourcePath
        let url = URL(string: path)
        assert(url != nil, """
            The path to the stub source is not a valid path.
            Choose a valid path in the stub source configuration.
            """)
        return PersistentStubSource(name: name, path: url!)
    }
}
