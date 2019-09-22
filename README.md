# The Stubborn Network

> A Swifty clean stubbing machine.

**The Stubborn Network** makes your SwiftUI development more efficient and UI tests more reliable by stubbing responses of your network requests. It makes it easy to record new stubs and takes the pressure from your backend during UI testing. It speeds things up! You can find usage examples in [The Stubborn Network Demo](https://github.com/q231950/the-stubborn-network-demo).

Stub network responses for stability and speed things up in

- 👮🏻‍♀️ [Unit Tests](https://github.com/q231950/the-stubborn-network/tree/improve-api#unit-tests)
- 🕵🏽‍♂️ [UI Tests](https://github.com/q231950/the-stubborn-network/tree/improve-api#ui-tests)
- 👩🏻‍🎨 [SwiftUI Previews](https://github.com/q231950/the-stubborn-network/tree/improve-api#swiftui-preview)

## 👮🏻‍♀️ Unit Tests

Unit Tests use "plain" stubs where each stub only lives for the duration of the test. This is called the _ephemeral_ configuration.

```swift
/// given
let session = StubbornNetwork.stubbed(withConfiguration: .ephemeral) { (stubbedSession) in
    stubbedSession.stub(NetworkClient.request, data: self.stubData, response: HTTPURLResponse(), error: nil)
}
let networkClient = NetworkClient(urlSession: session)

/// when
networkClient.post()

/// then
completion = networkClient.objectDidChange.sink { networkClient in
    XCTAssertEqual(networkClient.text, "417 bytes")
    exp.fulfill()
}
```

## 🕵🏽‍♂️ UI Tests

UI Tests benefit from **The Stubborn Network**'s ability to easily record actual network requests and then play them back. This is done via the _persistent_ configuration and a `.recording` mode.
In order to record and playback stubs you need to 
- configure your app to use a stubbed `URLSession` in its network layer when running tests. 
- the tests on the other hand are required to inform **The Stubborn Network** which stubs to use for which test case

### App Configuration

Instead of passing a standard `URLSession` to your network client a stubbed variant will be passed during UI test execution. This happens inside your application, for example a `SceneDelegate.swift`:

```swift
let urlSession: URLSession
let processInfo = ProcessInfo()

if processInfo.testing == false {
    /// Use the standard URLSession when not testing.
    urlSession = URLSession(configuration: .ephemeral)
} else {
    /// Use a stubbed URLSession when testing.
    urlSession = StubbornNetwork.stubbed(withProcessInfo: processInfo, stub: { (stubbedURLSession) in
    
        /// It is possible to record stubs instead of manually stubbing each request.
        stubbedURLSession.recordMode = .recording
    })
}
```

### Test Configuration

3 parameters are passed in as environment variables to the application under test in order to specify that we want to stub network responses, what to stub, where to find/place them. Some of these will be handled more elegantly in the future:

1. each test assigns its function name like `testBytesText` to create dedicated stubs for every individual test case
2. the _stub path_ points to the directory where the stubs are stored for `.playback` / will be recorded to with `.recording`
3. the _TESTING_ parameter simply makes indicates to the application (see _App Configuration_ above) that we are in a test environment.

```swift
override func setUp() {
    super.setUp()

    /// tell the app that we are executing tests right now
    app.launchEnvironment["TESTING"] = "TESTING"

    /// ... each stub's name will be the name of the test case
    app.launchEnvironment["STUB_NAME"] = self.name

    ///  .. and path to the stubs will be set to the project's directory
    let processInfo = ProcessInfo()
    app.launchEnvironment["STUB_PATH"] = "\(processInfo.environment["PROJECT_DIR"] ?? "")/stubs"
    app.launch()
}

func testBytesText() {
    /// In the test itself everything happens like with an untempered URLSession
    let bytesText = app.staticTexts["417 bytes"]
    wait(forElement:bytesText, timeout:2)
}
```

## 👩🏻‍🎨 SwiftUI Preview

```swift
static var previews: some View {
        let urlSession = StubbornNetwork.stubbed(withConfiguration: .persistent(name: "ContentView_Previews", path: "\(ProcessInfo().environment["PROJECT_DIR"] ?? "")/stubs")!) { (session) in
            session.recordMode = .playback
        }
        /// Use the stubbed `urlSession`...
}
```

## Stub structure

The stubs are stored as plain json to make the behaviour of the stubs transparent.

```json
[{
    "request": {
        "url": "https://api.abc.com",
        "headerFields": [
            "Accept-Encoding[:::]br, gzip, deflate"
        ],
        "method": "POST"
    },
    "data": "YWJj",
    "response": {
        "statusCode": 200,
        "headerFields": [
            "Content-Type[:::]text\/xml; charset=utf-8"
        ]
    }
}]
```
