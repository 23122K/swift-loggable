# Loggable
[![CI](https://github.com/23122K/swift-loggable/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/23122K/swift-loggable/actions/workflows/ci.yaml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/23122K/swift-loggable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F23122K%2Fswift-loggable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/23122K/swift-loggable)

A set of macros that support type-wide and per-function logging with ability to customize how logs are handled.

## Overview
There are many situations where logging additional information is helpful. However most of them are neglected as they reqire some boilerplate, this is especially present in bidirectional architectures. Loggable aims to simplify this  by providing macros that can:

* **Annotate all methods within type or extension**

There is no need to annotate each method individually - simply apply the desired annotation to the declaration, and let the magic happen. Standalone functions can also be annotated.

* **Customize how logs are handled**

All macros include the ability to add tags to logged functions, suppress their output or parameters, or ecent exclude the functions entirely from emmiting an event.

* **Leverage OSLog support**

Loggable provides macros that leverage Apple's OSLog framework, eliminating the need to manually create a [`Logger`](https://developer.apple.com/documentation/os/logger) instance, configure subsystems and categories, or log each function individually.


**On top of that**, Loggable does not bind you into any proprietary logging system - use the logger of you choice without compromising on convinence that comes with macros.

## Get started

You can start using Loggable in just two simple steps:

1. Import Loggable package and enable macros.
```swift
import Loggable
```

2. Mark desired type with `@Logged` annotation, eg.:
```
import Loggable
import SwiftData

@Logged
@ModelActor
actor SwiftDataClient {
  func save<T: PersistentModel>(_ model: T) throws {
    self.modelContext.insert(model)
    try self.modelContext.save()
  }
}
```

That's it! Now, whenever the `save` method is invoked, an event is emitted that captures metadata such as the location, signature, parameters, and result. For a more detailed guide, refer to the **[documentation]()**.

Alternatively, you can take advantage of the OSLog framework by switching to the following approach:

```
import Loggable
import SwiftData

@OSLogger
@OSLogged
@ModelActor
actor SwiftDataClient {
  func save<T: PersistentModel>(_ model: T) throws {
    self.modelContext.insert(model)
    try self.modelContext.save()
  }
}
```
The `@OSLogger` annotation introduces a static instance of [`Logger`](https://developer.apple.com/documentation/os/logger) , while `@OSLogged` implicitly makes every method within the annotated scope loggable. Refer to the **[documentation]()** to learn more.

## Learn More
Loggable offers a wide range of additional features. You can create custom loggers, add tags to captured events for later processing, exclude specific methods from logging, ignore certain parameters (or all of them) from being captured, override the log level for individual events, and much more. For usage examples and detailed information, see the **[documentation]()**.

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
