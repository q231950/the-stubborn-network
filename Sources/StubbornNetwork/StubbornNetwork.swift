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
public class StubbornNetwork {

    private let processInfo: ProcessInfo

    /// The standard Stubborn Network used be all clients
    public static let standard = StubbornNetwork()

    /// The bodyDataProcessor allows modification of stubbed body data.
    ///  - modify the request body before storing a stub
    ///  - modify the response body before storing a stub
    ///  - modify the response body just before delivering a stub
    public var bodyDataProcessor: BodyDataProcessor?

    private var persistentStubSource: StubSourceProtocol? {
        guard let location = StubSourceLocation(processInfo: ProcessInfo()) else { return nil }

        return PersistentStubSource(with: location)
    }

    var ephemeralStubSource: StubSourceProtocol?

    convenience init() {
        self.init(processInfo: ProcessInfo(), EphemeralStubSource())
    }

    init(processInfo: ProcessInfo? = ProcessInfo(),
         _ ephemeralStubSource: EphemeralStubSource?) {

        guard let processInfo = processInfo else { abort() }

        self.processInfo = processInfo
        self.ephemeralStubSource = ephemeralStubSource
    }
}

extension StubbornNetwork {

    /// Insert the `StubbedSessionURLProtocol` class into a given `URLSessionConfiguration`'s _protocolClasses_.
    /// Any configuration of a session is required to be passed into this method prior to being used in the initializer
    /// of `URLSession` - otherwise the protocol will not be used by _Foundation_'s URL Loading System.
    public func insertStubbedSessionURLProtocol(into configuration: URLSessionConfiguration) {
        configuration.protocolClasses?.insert(StubbedSessionURLProtocol.self, at: 0)
    }

    var stubSource: StubSourceProtocol {
        return CombinedStubSource(sources: [ephemeralStubSource, persistentStubSource].compactMap { $0 })
    }
}

// MARK: Module Internal Implementation Details

extension StubbornNetwork {

    static func persistentStubSource(withProcessInfo processInfo: ProcessInfo = ProcessInfo()) -> StubSourceProtocol {
        // temporary force unwrap since the this will go away anyways in the light of URL protocol based stubbing
        let location = StubSourceLocation(processInfo: processInfo)!
        return PersistentStubSource(with: location)
    }
}
