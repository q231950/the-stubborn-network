import Foundation

public struct RequestMatcherOptions: OptionSet {
 public let rawValue: Int

 public init(rawValue: Int) {
    self.rawValue = rawValue
}

 public static let url = RequestMatcherOptions(rawValue: 1 << 0)
 public static let httpMethod = RequestMatcherOptions(rawValue: 1 << 1)
 public static let headers = RequestMatcherOptions(rawValue: 1 << 2)
 public static let body = RequestMatcherOptions(rawValue: 1 << 3)

 public static let lenient: RequestMatcherOptions = [.url]
 public static let strict: RequestMatcherOptions = [.url, .httpMethod, .headers, .body]
}

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
    public static var standard: StubbornNetwork! {
        get {
            if _standard == nil {
                _standard = StubbornNetwork()
            }

            return _standard
        }
        set {
            _standard = newValue
        }
    }
    private static var _standard: StubbornNetwork?

    /// The matcher options for requests.
    ///
    /// More options will result in the requirement of the stubbed requests being very much like
    /// the actual requests. The `.lenient` option set for example only checks for the URL of a
    /// stub to decide if it should playback that stub or check the next one.
    public var requestMatcherOptions: RequestMatcherOptions = .strict

    /// The bodyDataProcessor allows modification of stubbed body data.
    ///  - modify the request body before storing a stub
    ///  - modify the response body before storing a stub
    ///  - modify the response body just before delivering a stub
    public var bodyDataProcessor: BodyDataProcessor?

    /// Removes the body data processor
    func removeBodyDataProcessor() {
        bodyDataProcessor = nil
    }

    var persistentStubSource: StubSourceProtocol? {
        guard let location = StubSourceLocation(processInfo: processInfo) else { return nil }

        return PersistentStubSource(with: location)
    }

    var ephemeralStubSource: StubSourceProtocol?

    public convenience init() {
        self.init(processInfo: ProcessInfo())
    }

    init(processInfo: ProcessInfo? = ProcessInfo(),
         _ ephemeralStubSource: EphemeralStubSource? = EphemeralStubSource()) {

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
        let sources = [ephemeralStubSource, persistentStubSource].compactMap { $0 }
        return CombinedStubSource(sources: sources)
    }
}
