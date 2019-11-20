![Travis](https://travis-ci.org/q231950/the-stubborn-network.svg?branch=master) [![SourceLevel](https://app.sourcelevel.io/github/q231950/the-stubborn-network.svg)](https://app.sourcelevel.io/github/q231950/the-stubborn-network)

# The Stubborn Network

> A Swifty and clean stubbing machine.

**The Stubborn Network** makes your _SwiftUI development more efficient_ and _UI tests more reliable_ by stubbing responses of your network requests. It makes it _easy to record new stubs_ and it speeds things up! You can find usage examples in [The Stubborn Network Demo](https://github.com/q231950/the-stubborn-network-demo) and below.

You can stub:

- 👮🏻‍♀️ [Unit Tests](https://github.com/q231950/the-stubborn-network/tree/master#unit-tests)
- 🕵🏽‍♂️ [UI Tests](https://github.com/q231950/the-stubborn-network/tree/master#ui-tests)
- 👩🏻‍🎨 [SwiftUI Previews](https://github.com/q231950/the-stubborn-network/tree/master#swiftui-preview)

## 👮🏻‍♀️ Unit Tests

Unit tests use "plain" stubs where each stub only lives for the duration of the test. This is called the _ephemeral_ configuration.

<details><summary><a href='https://github.com/q231950/the-stubborn-network-demo/blob/master/DemoTests/DemoTests.swift'>Unit Test Example</a></summary>
<p>

```swift
/// given we create an ephemeral stubbed session (the scope of the stubs stays within this test)
let session = StubbornNetwork.makeEphemeralSession()

/// and stub individual requests
session.stub(NetworkClient.request, data: self.stubData, response: HTTPURLResponse(), error: nil)

let networkClient = NetworkClient(urlSession: session)

/// when
networkClient.post()

/// then
completion = networkClient.objectDidChange.sink { networkClient in
    XCTAssertEqual(networkClient.text, "417 bytes")
    exp.fulfill()
}
```
</p>
</details>

## 🕵🏽‍♂️ UI Tests

UI tests benefit from **The Stubborn Network**'s ability to easily record actual network requests and then play them back. This is done via the _persistent_ configuration and a recording mode. In order to record and playback stubs you need to

- configure your app to use a stubbed `URLSession` in its network layer when running tests
- the tests on the other hand are required to inform **The Stubborn Network** which _stub sources_, in other words - which stubs to use for which test case

### App Configuration

Instead of passing a standard `URLSession` to your network client a stubbed variant will be passed during UI test execution. This happens inside your application, for example a `SceneDelegate.swift`:

<details><summary><a href='https://github.com/q231950/the-stubborn-network-demo/blob/master/Demo/SceneDelegate.swift'>Example App Configuration</a></summary>
<p>

```swift
if processInfo.testing == true {
    /// The session is persistent, which means that stubs are stored
    let urlSession = StubbornNetwork.makePersistentSession()

    /// `.playback` is the default, so after recording you can remove the following line or set it to .playback
    urlSession.recordMode = .record
}

let networkClient = NetworkClient(urlSession: urlSession)
```

</p>
</details>

### Test Configuration

There are 3 parameters passed in as environment variables to the application under test in order to specify that we want to stub network responses, what to stub, where to find/place them. Some of these will be handled more elegantly in the future:

1. each test assigns its function name like `testBytesText` to create a dedicated stub source with stubs for network requests of each individual test case
2. the _stub path_ points to the directory where the stub source with the stubs is stored for `.playback` / where stubs will be recorded to when `.recording`
3. the _TESTING_ parameter simply indicates to the application (see _App Configuration_ above) that we are in a test environment

<details><summary><a href='https://github.com/q231950/the-stubborn-network-demo/blob/master/DemoUITests/DemoUITests.swift'>UI Test Configuration</a></summary>
<p>

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

</p>
</details>

## 👩🏻‍🎨 SwiftUI Preview

A SwiftUI Preview utilizes **The Stubborn Network** mostly like a cache. You record and persist all network calls required to present a Preview and then have the responses available immediately for any successive Preview. This means you can record network calls and later show Previews without internet connection 🛩

<details><summary><a href='https://github.com/q231950/the-stubborn-network-demo/blob/master/Demo/ContentView.swift'>SwiftUI Example</a></summary>
<p>

```swift
static var previews: some View {
    let urlSession = StubbornNetwork.makePersistentSession(withName: "ContentView_Previews", path: "\(ProcessInfo().environment["PROJECT_DIR"] ?? "")/stubs")
    /// `.playback` is the default, so after recording you can remove the following line or set it to .playback
    urlSession.recordMode = .recording

    let networkClient = NetworkClient(urlSession: urlSession)
    /// Use the stubbed `networkClient`...
}
```

</p>
</details>

## Contribute

### Run Tests

You can run tests either from within Xcode (`cmd+U`) or from the command line: `export STUB_DIR='./stubs' && swift test`.
