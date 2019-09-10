# The Stubborn Network

> A Swifty clean stubbing machine.

**The Stubborn Network** makes your SwiftUI development more efficient and UI tests more reliable by stubbing responses of your network requests. It makes it easy to record new stubs to lower the burdon to take pressure from your backend during UI testing and to gate any actual network issues during your test runs. You can find usage examples in [The Stubborn Network Demo](https://github.com/q231950/the-stubborn-network-demo).

In order to make use of **The Stubborn Network** in your app you need to make a change to a single point in your app's sources as well as your UI tests:

- the client needs to be configured to use the stubbed `URLSession` in its network layer when running tests
- the UI tests need to inform **The Stubborn Network** which stubs to use for which test case

Since it's a Swift Package you need to add **The Stubborn Network** as a dependency to a Swift package manifest's build target. If you only have an app without any Swift packages so far, create a Swift package local to your workspace, add **The Stubborn Network** and link your local package in the app's _"Link Binary with Libraries"_ _Build Phase_.

Package manifest:

```Swift
dependencies: [
    .package(url: "https://github.com/q231950/the-stubborn-network.git",
        .branch("master")
    ),
],
```

The following setup with **Client Configuration** and **Usage in UI Tests** should show you the basic usage. Better guides are yet to come!

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
