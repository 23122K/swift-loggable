# Loggable
[![CI](https://github.com/23122K/swift-loggable/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/23122K/swift-loggable/actions/workflows/ci.yaml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/23122K/swift-loggable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/23122K/swift-loggable)

swift-loggable package is a set of macros that support type-wide and per-function logging with ability to customize how logs are handled.
## Learn More
Macros within this package can be loosely divided into four groups
### Log macros
Only supports functions, capturing their signature, source location, parameters, return values, and any errors thrown at runtime. As of now static, throwing, async, and generic functions are supported with standard arguments as well as inout arguments, closures, and @autoclosures.
> [!Note] 
> Passing traits directly to `@Log` or `@OSLog` has the same effect as using dedicated trait macros
#### `@Log` 
Accepts an optional `any Loggable` instance along with optional traits. Can be used standalone or within an `@Logged` context - when used inside `@Logged`, it overrides any parameters passed to `@Logged` in that context.
#### `@OSLog`
A specialized version of `@Log` that does not accept an `any Loggable` parameter as it uses [`Logger`](https://developer.apple.com/documentation/os/logger) introduced by `OSLogger` protocol
> [!warning]
> `@OSLog` must be used within a context annotated with `@OSLogger` or one that conforms to the `OSLogger` protocol
### Logged macros
Type-wide and extension macros that introduces `@Log` or `@OSLog` annotations to all methods within their scope. To omit function from being logged use `@Omit` macro without no parameters.
> [!Note] 
> Both `@Logged` and `@OSLogged` cannot be attached to protocols
#### `@Logged`
Takes `any Loggable` instance as a parameter. If provided, it is applied to all functions within its scope, unless explicitly opted out. By default, it uses [`Logger`](https://developer.apple.com/documentation/os/logger) with default subsystem.
#### `@OSLogged`
Specialized implementation of `@Logged` macro that marks all functions within its scope with `@OSLog`. Does not take any parameters. 
### Logger macro
Both macros internally rely on the [`Logger`](https://developer.apple.com/documentation/os/logger). Each macro allows for overriding the subsystem and category through parameters, with the default subsystem set to the bundle identifier and the default category set to the declaration name.
#### `@OSLogger`
Adds conformance to `OSLogger` protocol and introduces a static instance of [`Logger`](https://developer.apple.com/documentation/os/logger) to attached context. The control modifier is inherited from attached context. To override it, use `@OSLogger(access:)` overload. 
#### `#osLogger`
Creates a static instance of [`Logger`](https://developer.apple.com/documentation/os/logger) in the invoked context, without adding conformance to `OSLogger` protocol.
> [!Note] 
> `#osLogger` can only be declared on a type as it introduces static property 
### Trait macros
Can only by attached to functions and must always proceed `@Log` or `@OSLog` macros applied explicitly or implicitly by `@Logged` or `@OSLogged`.
> [!Note] 
> The only exception from this rule is `@Omit` with not parameters
#### `@Level`
Overrides level of which event is emitted. By default `@Log` and `@OSLog` level is set to [`.info`](https://developer.apple.com/documentation/os/oslogtype/info) when function succeeds or [`.error`](https://developer.apple.com/documentation/os/oslogtype/error) when error is thrown. [`OSLogType`](https://developer.apple.com/documentation/os/oslogtype) conforms to this protocol. 
#### `@Omit`
Can be used with or without parameters, in the last case  `@Logged` or `@OSLogged` macros will not be expanded. Currently `@Omit` allows to ignore omit result, specific parameter, or all parameters.
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
To log every method within `Foo`, simply annotate it with `@Logged`
```diff
+ @Logged
struct Foo { ... }
```
The code will be expanded as follows:
> [!Note] 
> Methods within extension of `Foo` will not be affected
```diff
@Logged
struct Foo { 
+ @Log
  func bar(...) async throws { ... }
  
+ @Log
  static func baz(...) -> Baz { ... }

+ @Log
  mutating func qux() { ...} -> Self
}

extension Foo { 
  static func quux() -> Self { ... }
}
```
To log a method inside an extension, you can either annotate it with `@Logged`, as shown earlier, or use `@Log`. Functions annotated with `@Log` expand to something like this:
```diff
extension Foo { 
+ @Log
  static func quux() -> Self {
+  let loggable: any Loggable = .logger
+  var event = LoggableEvent(
+    location: "Module/Foo.swift:13:37",
+    declaration: "mutating func quux() -> Self",
+    tags: []
+  )

+   func _static func quux() -> Self { ... }
+   let result =_quux()
+   event.result = .success(result)
+   loggable.emit(event: event)
+   return result
  }
}
```
#### Customs 
Loggable was built on the premise of not binding to a specific logging mechanism. To replace the default logic, conform the desired logger to the `Loggable` protocol, like this:
``` swift
struct NSLogger: Loggable {
  func emit(event: LoggableEvent) {
    NSLog("%@", event.description)
  }
}
```
Additionally, for nicer syntax create an extension for `Loggable`, as both `@Logged` and `@Log` accept `any Loggable` as a parameter. 
```swift
extension Loggable where Self == NSLogger {
  static var nsLogger: Self { NSLogger() }
}
```
Now, it can be passed as a parameter to either `@Log` or `@Logged` as follows:
```diff
extension Foo {
+ @Log(using: .nsLogger)
  static func quux() -> Self { ... }
}
```
When `.nsLogger` or any other type that conforms to `Loggable` protocol is passed as a parameter to `@Logged`, it is propagated to all methods within attached context.
```diff
@Logged(using: .nsLogger)
struct Foo { 
+ @Log(using: .nsLogger)
  func bar(...) async throws { ... }
  
+ @Log(using: .nsLogger)
  static func baz(...) -> Baz { ... }

+ @Log(using: .nsLogger)
  mutating func qux() { ...} -> Self
}
```
### @OSLogger, @OSLogged and @OSLog
Unlike the `@Logged` macro, to apply `@OSLog` to functions within a scope, the scope must first be annotated with `@OSLogger` or conform to the `OSLogger` protocol.
```diff
+ @OSLogger
struct Foo { ... }
```
After expansion, static instance of `logger` has been introduced to scope as well conformance to `OSLogger` protocol.
```diff
@OSLogger
struct Foo { ... }

+ extension Foo: OSLogger { 
+   static let logger = Logger(
+     subsystem: "Module"
+     category: "Foo"
+   )
+ }
```
Once conformed to the OSLogger protocol, we can add `@OSLogged`, which will apply `@OSLog` to each method within the scope.
```diff
@OSLogger
+ @OSLogged
struct Foo { ... }
```
Similarly to `@Logged`, it expands like this:
```diff
@OSLogger
@OSLogged
struct Foo { 
+ @OSLog
  func bar(...) async throws { ... }

+ @OSLog
  static func baz(...) -> Baz { ... }

+ @OSLog
  mutating func qux() { ...} -> Self
}

extension Foo { 
  static func quux() -> Self { ... }
}
```
> [!Note] 
> Methods within extension of `Foo` will not be affected

Subsystem or a category can be overridden by explicitly passing it as a parameter to `@OSLogger`. Order of `@OSLogger` and `@OSLogged` does not matter, they are expanded independently. Final code after expansion looks as follows:
```diff
@OSLogger(subsystem: "Example", category: "Readme")
@OSLogged
struct Foo { 
+ @OSLog
  func bar(...) async throws { ... }

+ @OSLog
  static func baz(...) -> Baz { ... }

+ @OSLog
  mutating func qux() { ...} -> Self
}

+ extension Foo: OSLogger { 
+   nonisolated static let logger = Logger(
+     subsystem: Bundle.main.bundleIdentifier ?? ""
+     category: "Readme"
+   )
+ }
```
Logger inherits declaration access level by default. To restrict its visibility, explicitly pass `_AccessLevelModifier` as a parameter, as shown below:
```diff
+ @OSLogger(access: .interal)
@OSLogged
public struct Foo<T> where T: Equatable { 
  // ...
}

+ extension Foo: OSLogger { 
+   nonisolated static var logger: Logger {
+     Logger(
+       subsystem: Bundle.main.bundleIdentifier ?? ""
+       category: "Readme"
+     )
+   }
+ }
```
### `#osLogger`
In cases where `@OSLogger` cannot be directly used on a type, you can create an extension for the desired type, add conformance to the `OSLogger` protocol, and invoke the `#osLogger` macro, like this:
```diff
+ extension Bar: OSLogger {
+   #osLogger
}
```
This is how the code will be expanded:
```diff
extension: Bar: OSLogger { 
+ static let logger = Logger(
+   subsystem: "Example"
+   category: "Readme"
+ )
}
```
### @Omit, @Tag and @Level
#### Basics
Each of this macros can be use together, excluding `@Omit` with not parameters as it would not make any sense. Using these macros is the same as providing parameters explicitly to `@Log` and `@OSLog`. Redundant parameters are ignored. Both of the following examples produce the same result.
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
extension Omittable where Self == OmittableTrait { 
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
> [!warning]
> `Omittable` internally uses `result` and `parameters` keywords, passing them as `String` into `@Omit()` or eg. `@Log(omit:)`, will not ignore a parameter named `result`, but will instead omit the actual function result from being captured.
##### Taggable
```swift
extension Taggable where Self == TaggableTrait { 
  static var biometrics: Self { .parameter("Biometrics") } 
}

extension Foo { 
  @Tag(.biometrics)
  @Log(using: .nsLogger)
  static func quux() -> Self { ... }
}
```
___
```swift
extension Foo { 
  @Log(using: .nsLogger, tag: "Biometrics")
  static func quux() -> Self { ... }
}
```
##### Levelable
```swift
extension Levelable where Self == LevelableTrait { 
  static var warning: Self { .level("warning") }
}

@Logged
extension Foo { 
  @Level(.warning)
  static func quux() -> Self { ... }
}
```
___
```swift
extension Foo { 
  @Log(level: "warning")
  static func quux() -> Self { ... }
}
```
## Installation
Add the following dependency to your Package.swift
```swift
.package(url: "https://github.com/23122K/swift-loggable.git", branch: "main"),
```
Alternatively, *Project → Package dependencies → + → Search or enter package URL* and paste 
```
https://github.com/23122K/swift-loggable.git
```
In both cases, choose dependency rule of your choice.
