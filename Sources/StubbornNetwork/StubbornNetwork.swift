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

    /// The nil resettable standard Stubborn Network
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

    var stubSource: StubSourceProtocol! {
        if _stubSource == nil {
            let sources = [ephemeralStubSource, persistentStubSource].compactMap { $0 }
            _stubSource = CombinedStubSource(sources: sources)
        }

        return _stubSource
    }

    fileprivate var _stubSource: StubSourceProtocol?

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

    /// Stubs a given request.
    ///
    /// When the client makes a request similar to the given `request`, data and response or error will be played back.
    ///
    /// - Parameters:
    ///   - request: the request to be stubbed
    ///   - data: this data will be played back.
    ///   - response: this response will be played back.
    ///   - error: this error will be played back. If an error is given it inhibits any data and response from
    ///            being replayed.
    public func stub(request: URLRequest,
                     data: Data? = nil,
                     response: URLResponse? = nil,
                     error: Error? = nil) {
        let stub = RequestStub(request: request,
                               response: response,
                               responseData: data,
                               error: error)
        stubSource.store(stub, options: requestMatcherOptions)
    }

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
}
