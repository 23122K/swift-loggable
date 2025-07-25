# Customizing macro behavior 

Customize macro behavior to suit your requirements.

## Overview

In this article, you will learn how to utilize trait macros and their associated traits to customize macro behavior.

Trait macros are macros used to pass parameters to a ``LoggableEvent``. They must always be preceded by either the ``Log(using:)`` or ``OSLog(level:omit:tag:)`` macros - either explicitly, or implicitly when a type is annotated with ``Logged(using:)`` or ``OSLogged()``, respectively. Otherwise, an error is emitted.

The trait macros include:

* ``Omit()``

Excludes the function from logging entirely - no event will be sent, whether function completes successfully or fails.

* ``Omit(_:)``

Omits specific ``Ommitable`` traits from being captured, such as individual parameters, all parameters, or the function's result metadata. In the last case, thrown errors are still captured.

* ``Tag(_:)``

Attaches tags to an event, allowing you to tailor logging behavior to fit your specific needs e.g. redaction, categorization filtering.

* ``Level(_:)``

Sets a logging level for the event, providing a clearer description of its severity or importance. By default, the level is set to ``.error`` if the function throws, and ``.info`` on success.

### Logging levels

Logging levels can be specified for an event using either overload of ``Log(using:level:omit:tag:)``, ``Level(_:)``, or a combination of both.

All of the examples below produce the same output.

Using ``Level(_:)`` within the type annotated with ``Logged(using:)``.
```swift
// SwipeableFactModel.swift

// ...
@Logged(using: .sentry)
class SwipeableFactModel {
  // ...
  @Level(.sentryDebug)
  func onSwipeToRight(_ fact: sending Fact) async throws {
    // ..
  }
  // ...
}
```

Using ``Level(_:)`` with a string that represents the logging level inside a type annotated with ``Logged(using:)``:

This example uses a predefined logging level. You can learn how to create custom ones in <doc:CreatingCustomLoggableInstance>

```swift
// SwipeableFactModel.swift

// ...
@Logged(using: .sentry)
class SwipeableFactModel {
  // ...
  @Level("debug")
  func onSwipeToRight(_ fact: sending Fact) async throws {
    // ...
  }
  // ...
}
```

Using ``Log(using:level:omit:tag:)`` with a specific level to log a single function within `SwipeableFactModel`
```swift
// SwipeableFactModel.swift

// ...
class SwipeableFactModel {
  // ...
  @Log(using: .sentry, level: "debug")
  func onSwipeToRight(_ fact: sending Fact) async throws {
    fact.isFavorite = true
    try self.storageClient.save(fact)
    try await getRandomFact()
  }
  // ...
}
```

Using both ``Log(using:)`` and ``Level(_:)``
```swift
// SwipeableFactModel.swift

// ...
class SwipeableFactModel {
  // ...
  @Level(.sentryDebug)
  @Log(using: .sentry)
  func onSwipeToRight(_ fact: sending Fact) async throws {
    fact.isFavorite = true
    try self.storageClient.save(fact)
    try await getRandomFact()
  }
  // ...
}
```

### Tags

Tags can be used to further customize the behavior of an event—for example, to redact sensitive information before the event is forwarded, or to enable more fine-grained handling of specific event types. You can add tags using any of the following:

* ``Log(using:level:omit:tag:)``
* ``Tag(_:)``
* Or a combination of both.

To pass a tag, simply use one of methods mentioned above, and pass desired value.

```swift
// FavoriteFactsModel.swift

extension FavoriteFactsModel {
  @Log(tag: "SwiftData")
  func deleteAllFavoriteFacts() throws {
    // ...
  }
}
```

For commonly used tags, you can leverage the ``Taggable`` protocol to define reusable and consistent tag definitions across your codebase.

```swift
// FavoriteFactsModel.swift

enum FavoriteFactsModelTags: Taggable {
  case tag(String)

  static var swiftData: Self {
    Self.tag("SwiftData")
  }

  init(stringLiteral value: StringLiteralType) {
    self = .tag(value)
  }
}
```

For cleaner and more expressive syntax, create a conditional extension for the ``Taggable`` protocol.

```swift
// FavoriteFactsModel.swift

extension Taggable where Self == FavoriteFactsModelTags {
  static var swiftData: any Taggable {
    self.swiftData
  }
}
```

Now, you can reuse the tag defined above and pass it as follows:

```swift
// FavoriteFactsModel.swift

extension FavoriteFactsModel {
  @Log(tag: .swiftData)
  func deleteAllFavoriteFacts() throws {
    // ...
  }
}
```

### Omiting metadata

There may be scenarios where logging function arguments or return values could expose sensitive information. While it's possible to process such metadata based on tags, it’s often simpler to omit it entirely from being captured. As shown in the examples above, this can be achieved using the ``Log(using:level:omit:tag:)`` macro overload, the ``Omit(_:)`` trait macro, or a combination of both.

If you want to exclude the method from logging altogether—on both success and failure-use `Omit()` without any parameters.

Loggable includes two predefined cases in the ``Omit`` enum:

* ``result``
  Strips the result metadata from the log. On success, the function is treated as returning `Void`.

* ``parameters``
  Omits all parameters passed to the logged function, preventing any argument data from being captured.


You can omit a specific parameter by passing a string that represents the **parameter name**.

> Important:
> Internally, when a function is logged, `Loggable` strips all **argument labels**.
> To ensure a parameter is correctly omitted from being captured, always use its **parameter name**, not the argument label.
> [Learn more about the difference between parameter names and argument labels.](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/functions#Function-Argument-Labels-and-Parameter-Names)


To exclude a function from being logged, simply mark it with `Omit()`.

```swift
// SwipeableFactModel.swift

// ...
@Logged(using: .sentry)
class SwipeableFactModel {
  // ...
  @Omit
  func fetchFavoriteFacts() throws {
    // ...
  }
}
```

To omit the result or all arguments passed to a logged function, use ``Omit(_:)`` and pass the ``result`` and ``parameters`` traits accordingly.

```swift
// StorageClient.swift

@OSLogged
extension StorageClient {
  // ...

  @Omit(.result)
  func delete<T: PersistentModel>(_ model: T) throws {
    // ...
  }
 
  @Omit(.result)
  func fetch<T: PersistentModel>() throws -> [T] {
     // ...
  }
}
```

To omit a specific parameter, you can pass a string representing the **parameter name**, as shown below:

```swift
// StorageClient.swift

@OSLogged
extension StorageClient {
  @Omit("model")
  func save<T: PersistentModel>(_ model: T) throws {
    // ...
  }
  // ...
}
```

Or, for commonly used parameters, you can create an extension to ``Omit`` and define them as static properties.

```swift
// StorageClient.swift

extension Omittable where Self == Omit {
  static var model: any Omittable {
    Omit.parameter("model")
  }
}
```

Then, you can simply refactor your code to pass ``model`` as an argument to ``Omit(_:)``.

```swift
// StorageClient.swift

@OSLogged
extension StorageClient {
  @Omit(.model)
  func save<T: PersistentModel>(_ model: T) throws {
    // ...
  }
  // ...
}
```
