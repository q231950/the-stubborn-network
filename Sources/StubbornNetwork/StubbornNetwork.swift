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

    /// Create a stubbed `URLSession`. The current `ProcessInfo`'s environment variables need to be setup for The Stubborn Network to know where the source of the stubs it should use have been persisted to.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    public static func stubbed(_ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {
        return stubbed(withProcessInfo: ProcessInfo(), stubbornURLSession)
    }

    /// Create a stubbed `URLSession` that lives in memory only. The stubs of this `StubbornURLSession` are not persisted anywhere. This factory method is useful in unit tests.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    public static func ephemeralStub(_ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {
        return stubbed(withConfiguration: .ephemeral, stubbornURLSession)
    }

    static func stubbed(withConfiguration configuration: StubSourceConfiguration = .ephemeral, _ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        let session: URLSessionStub

        /// TODO: Move this implementation to an internal static func on `URLSessionStub`
        switch configuration {
        case .ephemeral:
            session = URLSessionStub(configuration: .ephemeral, stubSource: EphemeralStubSource())
        case .persistent(let name, let path):
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

    /// Create a stubbed `URLSession` by providing a `ProcessInfo` that contains information about the location of the source for the stubs
    /// - Parameter processInfo: The process info that contains `EnvironmentVariableKeys` specifying the location of the stub source.
    /// - Parameter stubbornURLSession: The mutable `StubbornURLSession`. Use the closure's parameter to modify the record mode of the `StubbornURLSession` or to stub requests.
    static func stubbed(withProcessInfo processInfo: ProcessInfo, _ stubbornURLSession:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        /// TODO: Move this implementation to an internal static func on `URLSessionStub`
        let env = Environment(processInfo: processInfo)
        let name = env.stubSourceName
        let path = env.stubSourcePath
        assert(name != nil, "You have provided a process info but you are missing an environment variable called `\(EnvironmentVariableKeys.stubName)` that specifies the name of the current stub. Use the `stubbed(withConfiguration: .ephemeral)` if you are not intending to store stubs and keep them in memory instead.")
        assert(path != nil, "You have provided a process info but you are missing an environment variable called `\(EnvironmentVariableKeys.stubPath)` that specifies the path to the stub source. Use the `stubbed(withConfiguration: .ephemeral)` if you are not intending to store stubs and keep them in memory instead.")
        return stubbed(withConfiguration: .persistent(name: name!, path: path!), stubbornURLSession)
    }
}
