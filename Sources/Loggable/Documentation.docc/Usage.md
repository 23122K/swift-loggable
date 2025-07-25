# Getting started

Learn how to incorporate the ``Logged(using:)`` and ``Log(using:)`` macros into your project, how they work, and much more.

## Overview

This article showcases how to incorporate and use:
* ``Logged(using:)``

You will learn how to implicitly annotate each method inside a type or extension, how to provide a custom instance of `Loggable`, and how this instance is propagated.

* ``Log(using:)``

Explore how to capture events from specific functions and override the implicit conformance introduced by ``@Logged``.

* ``Omit()``

Opt out of logging and exclude methods from emitting events.

> Code examples used throughout this article are part of the example app [Count Me In]([Count Me In](https://github.com/23122K/swift-loggable/tree/main/Examples/CountMeIn)
> The first line in each code snippet refers to a file within the app.

## Import the Loggable library
After importing Loggable for the first time, you will be prompted to enable macros provided by the library.
```swift
// FavoriteFactsModel.swift
import Observation
import Loggable

// ...
```

## Mark a declaration with the @Logged macro
Mark `FavoriteFactsModel` with ``Logged(using:)`` annotation. Order in which this annotation is attached does not matter.
```swift
// FavoriteFactsModel.swift
// ...

@Logged
@MainActor
@Observable
class FavoriteFactsModel: Identifiable {
  let storageClient: StorageClient
  var facts: [Fact]

  func fetchFavoriteFacts() throws {
    self.facts = try self.storageClient.fetch()
  }

  func deleteFromFavoriteButtonTapped(_ fact: sending Fact) throws {
    try self.storageClient.delete(fact)
  }

  init(
    facts: [Fact] = [],
    storageClient: StorageClient = StorageClient.live
  ) {
    self.facts = facts
    self.storageClient = storageClient

    Task {
      for await _ in NotificationCenter.default.notifications(named: StorageClient.didSave) {
        try self.fetchFavoriteFacts()
      }
    }
  }
}

extension FavoriteFactsModel {
  func deleteAllFavoriteFacts() throws {
    for fact in self.facts {
      try self.storageClient.delete(fact)
    }
  }
}
```

This alone is sufficient for debugging. All methods within the `FavoriteFactsModel` scope are now implicitly marked with the ``Log(using:)`` annotation and will emit a `LoggableEvent` when invoked. Note that `deleteAllFavoriteFacts`, which is defined within an extension to `FavoriteFactsModel`, lies outside the scope of ``Logged(using:)`` and thus will not be affected.

By default, ``Logged(using:)`` uses the ``LoggableLogger`` instance. Refer to <doc:CreatingCustomLoggableInstance> for more information about incorporating custom loggers.

> Initializers are not implicitly marked with the ``Log(using:)`` annotation. Marking them explicitly also has no effect.

## Overriding @Logged behavior

Methods within the ``Logged(using:)`` scope can also be explicitly marked with the ``Log(using:)`` macro. In such cases, the annotation is overridden and will behave independently of ``Logged(using:)``.

```swift
// FavoriteFactsModel.swift
// ...

@Logged
@MainActor
@Observable
class FavoriteFactsModel: Identifiable {
  // ...

  func fetchFavoriteFacts() throws {
    self.facts = try self.storageClient.fetch()
  }

  @Log(using: .printer)
  func deleteFromFavoriteButtonTapped(_ fact: sending Fact) throws {
    try self.storageClient.delete(fact)
  }

  // ..
}

```
If we invoke both `fetchFavoriteFacts` and `deleteFromFavoriteButtonTapped`, the first will use the default logger, whereas the second will send an event to the `.printer` logger. This behavior can also be reversed. Refer to <doc:CreatingCustomLoggableInstance> for more information about incorporating custom loggers.

> Arguments provided to the `@Logged` macro are implicitly propagated to all methods within the declaration scope, unless explicitly opted out.

## Omit methods from being logged

Simply change the ``Log(using:)`` annotation to ``Omit()``. In this scenario, an event won’t be emitted when the function is invoked. The ``Omit(_:)`` macro also has an override, which you can learn more about in <doc:CustomizingMacroBehavior>.

```swift
// FavoriteFactsModel.swift
// ...

@Logged
@MainActor
@Observable
class FavoriteFactsModel: Identifiable {
  // ...

  @Omit
  func fetchFavoriteFacts() throws {
    self.facts = try self.storageClient.fetch()
  }

  func deleteFromFavoriteButtonTapped(_ fact: sending Fact) throws {
    try self.storageClient.delete(fact)
  }

  // ..
}
```

## Passing traits to @Log annotation
The ``Log(using:level:omit:tag:)`` macro supports traits that can be used to tailor its behavior. These traits can also be used used on their own, without ``Logged(using:)`` being attached to a scope.

```swift
// FavoriteFactsModel.swift
// ...

extension FavoriteFactsModel {
  @Log(tag: "Deletion")
  func deleteAllFavoriteFacts() throws {
    for fact in self.facts {
      try self.storageClient.delete(fact)
    }
  }
}
```

Upon invocation of `deleteAllFavoriteFacts`, the `"Delete"` tag will be passed along with the event. Learn more about traits in <doc:CustomizingMacroBehavior>.
