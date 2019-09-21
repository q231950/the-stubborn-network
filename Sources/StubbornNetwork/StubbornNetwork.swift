import Foundation

///
/// The Stubborn Network - a Swifty and clean stubbing machine.
///
/// The StubbornNetwork provides stubbed `URLSession`s. These `StubbornURLSession`s
/// can be used during tests to inject stubbed responses into your data structures
/// where normally a `URLSession` would be used to make network requests.
///
/// Stubbing your network can greatly improve flakiness in UI tests, is a common practice
/// for unit tests. You can also use stubbed network responses for running SwiftUI Previews
/// more efficiently
public struct StubbornNetwork {

<<<<<<< HEAD
    ///
    /// Use the `stubbedURLSession` to get an instance of StubbornURLSession
    ///
    /// Then stub requests:
    ///
    /// ```
    ///     let urlSession = StubbornNetwork.stubbedURLSession
    ///     urlSession.stub(request, data: stubbedData, response: nil, error: nil)
    /// ```
    //    public static var stubbedURLSession: URLSession {
    //        get {
    //            return URLSessionStub(configuration: .ephemeral, mode: .recording)
    //        }
    //    }

    /// , type: StubSourceType = .ephemeral ? maybe ?
    public static func stubbed(_ stub:((StubbornURLSession) -> Void)? = nil) -> URLSession {
        let session = URLSessionStub(configuration: .ephemeral)
=======
	///
    public static func stubbed(withProcessInfo processInfo: ProcessInfo, stub:((StubbornURLSession) -> Void)? = nil) -> URLSession {

			/// TODO: Move this implementation to an internal static func on `URLSessionStub`
        let env = Environment(processInfo: ProcessInfo())
        let name = env.stubSourceName
        let path = env.stubSourcePath
        assert(name != nil, "You have provided a process info but you are missing an environment variable called `\(Keys.stubName)` that specifies the name of the current stub. Use the `stubbed(withConfiguration: .ephemeral)` if you are not intending to store stubs and keep them in memory instead.")
        assert(path != nil, "You have provided a process info but you are missing an environment variable called `\(Keys.stubPath)` that specifies the path to the stub source. Use the `stubbed(withConfiguration: .ephemeral)` if you are not intending to store stubs and keep them in memory instead.")
        return stubbed(withConfiguration: .persistent(name: name!, path: path!), stub: stub)
    }

    public static func stubbed(withConfiguration configuration: StubSourceConfiguration = .ephemeral, stub:((StubbornURLSession) -> Void)? = nil) -> URLSession {

        let session: URLSessionStub

			/// TODO: Move this implementation to an internal static func on `URLSessionStub` and make `EphemeralStubSource` and `PersistentStubSource` internal
        switch configuration {
        case .ephemeral:
            session = URLSessionStub(configuration: .ephemeral, stubSource: EphemeralStubSource())
        case .persistent(let name, let path):
            let url = URL(string: path)
            assert(url != nil, "The path to the stub source is not a valid path. Choose a valid path in the stub source configuration.")
            let stubSource = PersistentStubSource(name: name, path: url!)
            session = URLSessionStub(configuration: .ephemeral, stubSource: stubSource)
        }

>>>>>>> Add documentation and leave some TODOs
        if let stub = stub {
            stub(session)
        }
        return session

    }
}

/// TODO: Move `StubSourceConfiguration` to its own file
///
/// StubSourceConfiguration defines the `URLSessionStub`s’ lifetime. They can either be ephemeral or they can be persisted on disk.
/// When persisting a stub source to disk, the path and name for the source have to be provided.
public enum StubSourceConfiguration {
    case ephemeral
    case persistent(name: String, path: String)
}
