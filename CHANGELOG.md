
**1.0.0**
_One_

This release bumps the Swift Version (https://github.com/q231950/the-stubborn-network/pull/57).

**0.1.3**
_Log info fixes_

This release fixes the problem when one of the stubs doesn't match and the log is not printed in console.

**0.1.2**
_Body matcher comparison_

This release fixes the `httpBody` comparison to address an issue when keys in JSON payload are sorted differently. 

**0.1.1**

_Proper CombinedStubSource_

This release is a minor improvement that corrects the `CombinedStubSource` behaviour to properly aggregate its children's `recordMode`.

**0.1.0**

_Cocoapods and Multiple Similar Requests_

This release incorporates support to record the same request multiple times. If the same request (a duplicate) gets send multiple times the `PersistentStubSource` will record it as 2 distinct entries in the resulting stub file.

[Here is a test](https://github.com/q231950/the-stubborn-network/blob/main/Tests/StubbornNetworkTests/PersistentStubSourceTests.swift#L102-L116) that showcases the result of the change.

When serving requests **The Stubborn Network** consumes available stubs for a given request. This means that if the same request was stubbed 2 times it may be requested later on 2 times - a third request will not be served as a stub any more.

An additional change is support for Cocoapods.


**0.0.7**

_Bond._

The biggest change in this release is the way the stubbing mechanism intercepts requests to return recorded responses. A *The Stubborn Network* `URLProtocol` is now applied to your URLSession's configuration instead of subclassing a `URLSession`. Stubs are now recorded automatically when a test doesn't have corresponding stubs. Besides that some improvements were made to give more control over the request matching of outgoing requests and available stubs.

- set *The Stubborn Network* URLProtocol to your URLSession instead of subclassing one
- stubs are recorded automatically (record modes are not needed any more)
- request bodies are now stored in the stubs
- allow for request matching options from `.lenient` to `.strict` and anything in between
- during recording successive, similar requests will now respond with the original server response instead of playing back a initially recorded response

Thanks to the members of Cocoaheads Hamburg and the iOS community for their input for this release.

**0.0.6**

_New Record Mode and Body Control_

This release is giving a lot more control over the stubs' request and response body data. It is now possible to specify exactly what gets stored into a stub and what doesn't. For example credentials could be filtered out of the body data of a request before being stored as a stub. Another great feature is the ability to modify a response's data just before it gets delivered - if you ever had the need to adjust time stamps so that the stubs will be accepted by your app - now you can! As a hygiene factor this release gets rid of all linter warnings of the project 🧼

A new record mode allows to record only new requests and new stubs. This mode will improve the experience when adding new UITests a lot. No more stashing of the record mode after adding your new tests 😃

Test coverage is up to 89.7% which should give a lot of confidence for working on the open issues.
