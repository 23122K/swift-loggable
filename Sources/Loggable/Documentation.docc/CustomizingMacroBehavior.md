# Customizing macro behavior 

Customize macro behavior to suit your requirements.

## Overview

In this article, you will learn how to utilize trait macros to customize macro behavior.

## "Trait" macros

Trait macros are macros used to pass parameters to a `LoggableEvent`. They must always be preceded by either the `@Log` or `@OSLog` macros - either explicitly, or implicitly when a type is annotated with `@Logged` or `@OSLogged`, respectively. Otherwise, an error is emitted.

The trait macros include:
* `@Omit` - Omits function from sending an event
* `@Omit(_ traits: any Omittable...)` - Omit function from capturing Ommitable trait e.g. parameter or result
* `@Tag(_ traits: any Taggable...)` - Associates tags with an event
* `@Level(_ trait: (any Levelable)? = nil)` - Associates logging level with an event

### Logging levels

Logging levels can be specified for an event using either overload of `@Log(level: (any Levelable)? = nil)`, `@Level(any Levelable)`, or a combination of both.

All of the examples below produce the same output.

Using `@Level` within the type annotated with `@Logged`.
```swift
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

Using `@Level` with a string that represents the logging level inside a type annotated with `@Logged`:

```swift
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

Using `@Log` with a specific level to log a single function within `SwipeableFactModel`
```swift
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

Using both `@Log` and `@Level`.
```swift
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

### Logged annotation

Now, simply mark any top level declaration with ``Logged(using:)`` macro and let the magic happen.
Every function within declaration is now implicity anottated with ``Log(using:)`` macro.
```swift
import Loggable
import SwiftUI

class PandaCollectionFetcher: ObservableObject {
  @Published var imageData = PandaCollection(sample: [Panda.defaultPanda])
  @Published var currentPanda = Panda.defaultPanda

  let urlString = "http://playgrounds-cdn.apple.com/assets/pandaData.json"

  enum FetchError: Error {
    case badRequest
    case badJSON
  }

  func fetchData() async
  throws  {
    guard let url = URL(string: urlString) else { return }

    let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

    Task { @MainActor in
      imageData = try JSONDecoder().decode(PandaCollection.self, from: data)
    }
  }
}
```

### Thats it!

