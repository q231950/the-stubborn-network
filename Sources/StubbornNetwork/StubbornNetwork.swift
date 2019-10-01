import Foundation

///
/// The Stubborn Network - a Swifty and clean stubbing machine.
///
/// The StubbornNetwork provides stubbed `URLSession`s. These `StubbornURLSession`s
/// can be used during tests to inject stubbed responses into your data structures
/// where normally a `URLSession` would be used to make network requests.
///
/// Stubbing your network can greatly improve flakiness in UI tests and is a common practice
/// for unit tests. You can also use stubbed network responses for running SwiftUI Previews
/// more efficiently where the stubs act like a cache.
public struct StubbornNetwork {

    /// Shorthand for a `StubbornURLSession` with a `.ephemeral` configutation. Creates a stubbed `URLSession` that lives in memory only. The stubs of this `StubbornURLSession` are not persisted anywhere. This factory method is useful in unit tests.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    public static func ephemeralStubbedURLSession(_ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {
        return stubbed(withConfiguration: .ephemeral, stubbornURLSession)
    }

    /// Create a stubbed `URLSession` by providing a `ProcessInfo` that contains information about the location of the source for the stubs
    /// - Parameter processInfo: The process info that contains `EnvironmentVariableKeys` specifying the location of the stub source.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    public static func persistedStubbedURLSession(withProcessInfo processInfo: ProcessInfo, _ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        /// TODO: Move this implementation to an internal static func on `URLSessionStub`
        let location = StubSourceLocation(processInfo: processInfo)
        return stubbed(withConfiguration: .persistent(location: location), stubbornURLSession)
    }

    static func persistedStubbedURLSession(withName name: String, path: String, _ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        /// TODO: Move this implementation to an internal static func on `URLSessionStub`
        let location = StubSourceLocation(name: name, path: path)
        return stubbed(withConfiguration: .persistent(location: location), stubbornURLSession)
    }

    ///    Creates a stubbed `URLSession` with a configuration.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    /// - Parameter configuration
    static func stubbed(withConfiguration configuration: StubSourceConfiguration = .ephemeral, _ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        let session: URLSessionStub

        /// TODO: Move this implementation to an internal static func on `URLSessionStub`
        switch configuration {
        case .ephemeral:
            session = URLSessionStub(configuration: .ephemeral, stubSource: EphemeralStubSource())
        case .persistent(let location):
            let name = location.stubSourceName
            let path = location.stubSourcePath
            let url = URL(string: path)
            assert(url != nil, "The path to the stub source is not a valid path. Choose a valid path in the stub source configuration.")
            let stubSource = PersistentStubSource(name: name, path: url!)
            session = URLSessionStub(configuration: .ephemeral, stubSource: stubSource)
        }

        if let stubbornURLSession = stubbornURLSession {
            stubbornURLSession(session)
        }
        return session
    }
}
