# Loggable
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/23122K/swift-loggable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/23122K/swift-loggable)
Loggable is a set of macros that support type-wide and per-function logging with ability to customize how logs are being handled.
## Learn More
This package comes with few macros which can be loosely divided into three groups.
### Log macros
Attachable to functions only, responsible for capturing function signature, location, parameters result or errors thrown within. As of now support static, throwing, async, and generic functions with standard arguments as well as inout arguments, closures, and @autoclosures.
#### `@Log` 
Takes `any Loggable` and traits as parameters. Can be used stand-alone or within `@Logged` scope - in this case it will override parameters passed to `@Logged`. Passing traits into `@Log` has the same effect as using dedicated Trait macros.
#### `@OSLog`
Specialized version of `@Log`, does not take `any Loggable` as a parameter and must always be within scope annotated with `@OSLogged`.
### Logged macros
Type-wide and extension macros that introduces `@Log` or `@OSLog` annotations to all methods within their scope. To opt-out of function logging in both cases use `@Omit` macro without any parameters.
> :warning: Both `@Logged` and `@OSLogged` cannot be attached to protocols.
#### `@Logged`
Takes `any Loggable` as parameter, when provided, propagates it to all functions within scope unless explicitly opted out. By default it uses `OSSignposter` with with `OSLog.default` instance. 
#### `@OSLogged`
Specialized implementation of `@Logged` that internally depends and introduces static instance of [`Logger`](https://developer.apple.com/documentation/os/logger) to attached context. Allows to override subsystem or category via parameters, default subsystem being a bundle identifier and declaration name as category. Does not propagate any passed parameters.
### Trait macros
Can only by attached to functions and must always proceed `@Log` or `@OSLog` macros added explicitly or implicitly by `@Logged` or `@OSLogged`. Allows for customize what is being logged, add tags, level to emitted event. 
> :note: The only exception from this rule is `@Omit` when it does not specify any traits as parameters.
#### `@Level`
Specifies with what level event should be emitted with. Trait must conform to `Levelable` protocol. As of now only `OSLogType` conforms to this protocol. 
#### `@Omit`
Can be used with parameters or without, in the last case  `@Logged` or `@OSLogged` macros will not be expanded. Its parameters must conform to `Omittable` protocol. Currently `Omittable` allows to omit capturing of function:
* Result
* Parameter 
* All parameters
#### `@Tag` 
Takes range of parameters that conforms to `Taggable` protocol. Passed parameters are attached to emitted event.
## Usage
Consider this code as a starting point
```swift
struct Foo { 
  func bar(...) async throws -> Bar { ... }
  
  static func baz(...) -> Baz { ... }
  
  func qux() { ... }
}

extension Foo { 
  mutating func quux() -> Self { ... }
}
```
### @Logged and @Log
#### Basics
To log every method within `Foo`, simply mark it with `@Logged` annotation
```diff
+ @Logged
struct Foo { ... }
```
Now, underneath this code will be expanded like this.
> :note: Method within extension of `Foo` will not be affected
```diff
@Logged
struct Foo { 
+  @Log
  func bar(...) async throws { ... }
  
+  @Log
  static func baz(...) -> Baz { ... }

+  @Log
  mutating func qux() { ...} -> Self
}

extension Foo { 
  static func quux() -> Self { ... }
}
```
To log method inside extension we can annotate it with `@Logged` as shown previously or mark it with `@Log`, functions annotated with `@Log` expands to something like this:
```diff
extension Foo { 
+   @Log
  static func quux() -> Self {
+  let loggable: any Loggable = .signposter
+  var event = LoggableEvent(
+    location: "Module/Foo.swift:13:37",
+    declaration: "mutating func quux() -> Self",
+    tags: []
+  )

+   func _static func quux() -> Self { ... }
+   let result = _quux()
+   event.result = .success(result)
+   loggable.emit(event: event)
+   return result
  }
}
```
#### Customs 
Loggable was build on premise to not tie anyone with logging mechanism, to swap out default logic start with conforming your desired logger to `Loggable` protocol like that.
``` swift
struct NSLogger: Loggable {
  func emit(event: LoggableEvent) {
    NSLog("%@", event.description)
  }
}
```
Then, for nicer syntax create extension for `Loggable` as both `@Logged` and `@Log` take `any Loggable` as a parameter.
```swift
extension Loggable where Self == NSLogger {
  static var nsLogger: Self { NSLogger() }
}
```
Now u can pass it as a parameter to `@Log` or `@Logged`.
```diff
extension Foo {
+  @Log(using: .nsLogger)
  static func quux() -> Self { ... }
}
```
When `.nsLogger` is passed as parameter to `@Logged`, it is propagated to all methods within.
```diff
@Logged(using: .nsLogger)
struct Foo { 
+   @Log(using: .nsLogger)
  func bar(...) async throws { ... }
  
+  @Log(using: .nsLogger)
  static func baz(...) -> Baz { ... }

+  @Log(using: .nsLogger)
  mutating func qux() { ...} -> Self
}
```
### @OSLogged and OSLog
Likewise `@Logged`, simply annotate with `@OSLogged` to log all methods within `Foo` scope.
```diff
+ @OSLogged
struct Foo { ... }
```
This will be expanded into code like this
> :note: Method within extension of `Foo` will not be affected, but in this case extension cannot be  annotated with`@OSLogged` as second instance of `logger` will be declared.
```diff
@OSLogged
struct Foo { 
+  @OSLog
  func bar(...) async throws { ... }
  
+  @OSLog
  static func baz(...) -> Baz { ... }

+  @OSLog
  mutating func qux() { ...} -> Self

+  static let logger = Logger(
+    subsystem: "Module"
+    category: "Foo"
+  )
}

extension Foo { 
  static func quux() -> Self { ... }
}
```
As of now, to log methods within extension scope we either must move `@OSLogged` declaration there or mark each individually.
```diff
extension Foo { 
+  @OSLog
  static func quux() -> Self { ... }
}
```
Subsystem or category can be overridden by explicitly passing it as a parameter to `@OSLogged` 
```diff
@OSLogged(subsystem: "Example", category: "Readme")
struct Foo { 
+  @OSLog
  func bar(...) async throws { ... }
  
+  @OSLog
  static func baz(...) -> Baz { ... }

+  @OSLog
  mutating func qux() { ...} -> Self

+  static let logger = Logger(
+    subsystem: "Example"
+    category: "Readme"
+  )
}
```
### @Omit, @Tag and @Level
#### Basics
Each of this macros can be use together, excluding plain `@Omit` as it would not make any sense. Using this macros is the same as providing parameters explicitly to `@Log` and `@OSLog`. Redundant parameters are ignored. Both of this examples are the same.
```swift
extension Foo { 
  @Log(level: .debug, omit: .result, tag: "Example")
  static func quux() -> Self { ... }
}
```
___
```swift
extension Foo { 
  @Tag("Example)
  @Level(.debug)
  @Omit(.result)
  @Log
  static func quux() -> Self { ... }
}
```
#### Customs 
Each of this macros comes with their own protocol, `Omittable`, `Taggable` and `Levelable`. All protocols conforms to `Sendable & Hashable & ExpressibleByStringLiteral`. In each section below, both examples produces the same output.
##### Omittable 
```swift
extension Omittable { 
  static var privateKey: Self { .parameter("privateKey") } 
}

@OSLogged
extension Foo { 
  @Omit(.privateKey)
  static func quux(privateKey: Data) -> Self { ... }
}
```
___
```swift
@OSLogged
extension Foo { 
  @OSLog(omit: "privateKey")
  static func quux(privateKey: Data) -> Self { ... }
}
```
> :warning: `Omittable` internally uses `result` and `parameters` names, passing them as `String` into `@Omit()` or eg. `@Log(omit:)` will not ignore capturing of a parameter named eg. `result` but  function result will be omitted. To omit parameters that uses reserved names use `.parameter("result")` 
##### Taggable
```swift
extension Taggable { 
  static var biometrics: Self { .parameter("Biometrics") } 
}

extension Foo { 
  @Tag(.biometrics)
  @Log(using: .nsLogger)
  static func quux(privateKey: Data) -> Self { ... }
}
```
___
```swift
extension Foo { 
  @Log(using: .nsLogger, tag: "Biometrics")
  static func quux(privateKey: Data) -> Self { ... }
}
```
##### Levelable
```swift
extension Levelable { 
  static var warning: Self { .level("warning") } //
}

@Logged
extension Foo { 
  @Level(.warning)
  static func quux(privateKey: Data) -> Self { ... }
}
```
___
```swift
extension Foo { 
  @Log(level: "warning")
  static func quux(privateKey: Data) -> Self { ... }
}
```
## Installation
Add the following dependency to your Package.swift
```swift
.package(url: "https://github.com/23122K/swift-loggable.git", branch: "main"),
```
Alternatively, *Project → Package dependencies → + → Search or enter package URL* and paste 
```
https://github.com/23122K/swift-loggable.git`
```
In both cases choose dependency rule of your choice
