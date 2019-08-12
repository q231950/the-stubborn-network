# The Stubborn Network

A Swifty clean stubbing machine.

```Swift
let network: NetworkClient

if let env = Environment.current, env.testing {
    /// Use a stubbed URLSession when testing.
    let session = StubbornNetwork.stubbed { (stub) in

        /// Enable recording of new stubs. The default value is `.playback`.
        stub.recordMode = .recording

        if let name = env.stubSourceName, let path = env.stubSourcePath {
            stub.setupStubSource(name:name, path: path)
        }
    }

    network = NetworkClient(session: session)
} else {
    /// Use the standard URLSession when not testing.
    let session = URLSession(configuration: URLSessionConfiguration.default)
    network = NetworkClient(session: session)
}
```
