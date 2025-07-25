# Leverage OSLog framework

Learn how to leverage ``OSLogger(access:subsystem:category:)``, ``OSLogged()`` and ``OSLog(level:omit:tag:)``

## Overview

This article explains how to leverage the [`Logger`](https://developer.apple.com/documentation/os/logger) from the OSLog framework to send all events through it.

### Import the loggable library

To import loggable library, add the following to the Swift source file.
```swift
// StorageClient.swift

import Loggable
```
### Conform to ``OSLogger`` protocol

You can either conform to this protocol manually—its only requirement is a static instance of [`Logger`](https://developer.apple.com/documentation/os/logger) - or use ``OSLogger(access:subsystem:category:)`` to automatically synthesize the conformance. You only need to do this once; afterward, you can use the logger to record additional information, and macros will tap into it to send events.

```swift
@OSLogger
@MainActor
struct StorageClient: Sendable {
  // ...
}
```

``OSLogger(access:subsystem:category:)`` allows you to override the access level used to create the [`Logger`](https://developer.apple.com/documentation/os/logger) instance, as well as specify the subsystem and category. By default, the subsystem is set to `Bundle.main.bundleIdentifier ?? ""`, while the category defaults to the declaration name - `StorageClient` in above case.


### Capturing Events into Logger

Now that we conform to the ``OSLogger`` protocol, we can simply mark either the type itself with ``@OSLogged()`` or, for example, an extension containing its methods. This way, all functions within that extension are automatically logged. You can learn more about customizing their behavior in <doc:CustomizingMacroBehavior>.

```swift
@OSLogged
extension StorageClient {
  func save<T: PersistentModel>(_ model: T) throws {
    // ...
  }
  
  func delete<T: PersistentModel>(_ model: T) throws {
    // ...
  }
 
  func fetch<T: PersistentModel>() throws -> [T] {
    // ...
  }
}
```

### Logging a Single Function

If you only want to log a single method, there’s no need to mark the entire extension with ``@OSLogged()``. Instead, you can use ``@OSLog(level:omit:tag:)`` directly on that method. This way, events will be captured only for that specific function.

```swift
extension StorageClient {
  @OSLog
  func save<T: PersistentModel>(_ model: T) throws {
    // ...
  }
}
```
