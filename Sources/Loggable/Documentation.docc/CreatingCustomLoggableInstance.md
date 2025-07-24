# Defining custom Loggable instance

Define custom Loggable instance and use it with macros.

## Overview

This article focuses on creating a custom `Loggable` instance.
Below example depends on [SentrySDK](https://github.com/getsentry/sentry-cocoa) Additionaly, you can create a free account on [sentry.io](http://sentry.io/) and provide your own dns to see events in action.

### Import Sentry and the Loggable library

Since we will be extending types from both libraries, their imports must be marked as public.
```swift
public import Loggable
public import Sentry
```

### Conform to Loggable protocol

Loggable protocol has two requirements, conforming type must:
* Be `Sendable`
* Implement `emit(event: LoggableEvent)` method

This method is called each time a function either completes successfully or throws an error.

```swift
public import Loggable
public import Sentry

struct SentryLogger: Loggable {
  func emit(event: LoggableEvent) {
    // ...
  }
}
```

### Leverage Sentry's breadcrumbs and scope

Note that not all events emitted via `emit(event: LoggableEvent)` represent errors - successful completions of functions are also captured. We can leverage this by using Sentry's ability to attach breadcrumbs to errors when they occur, effectively creating a backtrace of user actions leading up to the failure.

> Note:
> Learn more about [breadcrumbs](https://docs.sentry.io/product/issues/issue-details/breadcrumbs/) and [scopes](https://docs.sentry.io/platforms/apple/guides/ios/enriching-events/scopes/).

```swift
extension LoggableEvent {
  var sentryBreadcrumb: Sentry.Breadcrumb {
    let breadcrumb = Sentry.Breadcrumb()
    if let level = self.level as? SentryLevel {
      breadcrumb.level = level
    }
    breadcrumb.category = "Action"
    breadcrumb.type = "user"
    breadcrumb.message = self.description
    return breadcrumb
  }

  var sentryErrorTags: [String: String] {
    [
      "error.function.signature": self.declaration,
      "error.function.parameters": self.parameters.mapValues { String(reflecting: $0) }.description,
      "error.function.location": self.location,
    ]
  }
}

```

### Implement logic

Now that we've identified the information to log on both success and failure, it's time to implement the logic that will run when the emit method is invoked.

```swift
public import Sentry
public import Loggable

struct SentryLogger: Loggable {
  func emit(event: LoggableEvent) {
    switch event.result {
      case .success:
        SentrySDK.addBreadcrumb(event.sentryBreadcrumb)

      case let .failure(error):
        SentrySDK.capture(error: error) { scope in
          scope.setTags(event.sentryErrorTags)
        }
    }
  }
}
```

We can check weather function was that logger was attached to emited an event on success or failure by checking `event.resut`.

On failure, we use `SentrySDK.capture(error:)`, passing in the error that triggered the event. Before sending the error to Sentry, we attach relevant metadata to the scope, providing additional context. Upon success, we simply add a breadcrumb that will be sent along with an error.

### Loggable extension

For cleaner syntax and easier usage of `SentryLogger`, create an extension to the Loggable protocol and declare a conditional conformance to it.

```
extension Loggable where Self == SentryLogger {
  static var sentry: any Loggable {
    SentryLogger()
  }
}
```

> Warning:
> When creating an extension, always use `any Loggable` as a type, otherwise `@Logged` macro will not work.

### Custom logger levels

Each logger will likely have its own predefined set of logging levels. To integrate them with macros, simply conform to the `Levelable` protocol.

Levelable requires that a type is `Sendable`, `ExpressibleByStringLiteral`, and implements the static method `static func level(_ value: RawValue) -> Self`.

Sentry levels are represented by the `SentryLevel` enum. To make it conform to `Levelable`, start by adding conformance to `Sendable` and `ExpressibleByStringLiteral`.

```swift
extension SentryLevel: @retroactive @unchecked Sendable {}
extension SentryLevel: @retroactive ExpressibleByStringLiteral {}
```

Now, we must fulfill the requirements of both the `Levelable`  and `ExpressibleByStringLiteral` protocols.

To satisfy `Levelable` protocol, define the required static function where the `RawValue` type matches the underlying type of the extended logging level, in case of `SentryLevel` it is `UInt`. Provide a fallback level of your choice for values that don’t match predefined cases.

Additionally, implement the `ExpressibleByStringLiteral` initializer. This is necessary because the `@Level` macro allows you to pass either a string literal (e.g. `@Level("fatal")`) or `any Levelable` type (e.g. `@Level(sentryFatal)`), both of which should result in the same `SentryLevel.fatal` value.

```swift
extension SentryLevel: @retroactive Levelable {
  public static func level(_ value: UInt) -> Self {
    SentryLevel(rawValue: value) ?? SentryLevel.none
  }

  public init(stringLiteral value: StringLiteralType) {
    switch value {
      case "none":
        self = SentryLevel.none

      case "debug":
        self = SentryLevel.debug

      case "info":
        self = SentryLevel.info

      case "warning":
        self = SentryLevel.warning

      case "error":
        self = SentryLevel.error

      case "fatal":
        self = SentryLevel.fatal

      default:
        self = SentryLevel.none
    }
  }
}
```

### Levelable extension

As previously mentioned, macros such as `@Level` and `@Log(level:)` overload accept any type conforming to `Levelable` as a parameter. For a cleaner and more intuitive syntax, add a conditional conformance to the Levelable protocol.

> Tip:
> String conforms to `Levelable` protocol.

```swift
extension Levelable where Self == SentryLevel {
  static var sentryNone: any Levelable {
    SentryLevel.none
  }

  static var sentryDebug: any Levelable {
    SentryLevel.debug
  }

  static var sentryInfo: any Levelable {
    SentryLevel.info
  }

  static var sentryWarning: any Levelable {
    SentryLevel.warning
  }

  static var sentryError: any Levelable {
    SentryLevel.error
  }

  static var sentryFatal: any Levelable {
    SentryLevel.fatal
  }
}
```

