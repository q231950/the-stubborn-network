# The Stubborn Network

A Swifty clean stubbing machine.

---

## Client Configuration

Adding support for the Stubborn Network in the App:

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

## Usage in UI Tests

3 parameters are passed in as environment variables to the application under test in order to specify that we want to stub network responses, what to stub, where to find/place them. Some of these will be handled more elegantly in the future:

- each test assigns its function name like `testWaveVisibleAfterSignIn` to create dedicated stubs for every individual test case
- the _stub path_ points to the directory where the stubs are stored for `.playback` / will be recorded to with `.recording`
- the _TESTING_ parameter simply makes sure that we are in a testing environment.

```Swift
override func setUp() {
    app = XCUIApplication()
    let p = ProcessInfo()

    app.launchEnvironment["TESTING"] = "TESTING"
    app.launchEnvironment["STUB_NAME"] = self.name
    app.launchEnvironment["STUB_PATH"] = p.environment["PROJECT_DIR"]

    app.launch()
}
```

## Stub structure

The stubs are stored as plain json to make the behaviour of the stubs transparent.

```json
[{"request":{"url":"https:\/\/zones.buecherhallen.de\/app_webuser\/WebUserSvc.asmx","headerFields":["Accept-Language[:::]en-us","Accept[:::]*\/*","SOAPAction[:::]http:\/\/bibliomondo.com\/websevices\/webuser\/CheckBorrower","Content-Type[:::]text\/xml; charset=utf-8","Accept-Encoding[:::]br, gzip, deflate"],"method":"POST"},"data":"PD94bWwgdmVyc2lvbj0","response":{"statusCode":200,"headerFields":["X-Powered-By[:::]ASP.NET","Content-Type[:::]text\/xml; charset=utf-8","Vary[:::]Accept-Encoding","Content-Length[:::]617","Content-Encoding[:::]gzip","Server[:::]Microsoft-IIS\/8.0","Cache-Control[:::]private, max-age=0","X-AspNet-Version[:::]2.0.50727","Date[:::]Mon, 12 Aug 2019 18:28:29 GMT"]}},{"request":{"url":"https:\/\/zones.buecherhallen.de\/app_webuser\/WebUserSvc.asmx","headerFields":["Accept-Language[:::]en-us","Accept[:::]*\/*","Content-Type[:::]text\/xml; charset=utf-8","Accept-Encoding[:::]br, gzip, deflate","SOAPAction[:::]http:\/\/bibliomondo.com\/websevices\/webuser\/GetBorrowerLoans"],"method":"POST"},"data":"PD94bWwgdmVyc","response":{"statusCode":200,"headerFields":["X-Powered-By[:::]ASP.NET","Content-Type[:::]text\/xml; charset=utf-8","Vary[:::]Accept-Encoding","Content-Length[:::]377","Content-Encoding[:::]gzip","Server[:::]Microsoft-IIS\/8.0","Cache-Control[:::]private, max-age=0","X-AspNet-Version[:::]2.0.50727","Date[:::]Mon, 12 Aug 2019 18:28:30 GMT"]}}]
```
