# Customizing macro behavior 

Customize macro behavior to suit your requirements.

## Overview

This article will be based on sample project release by apple - [memecreator](https://developer.apple.com/tutorials/sample-apps/memecreator)

### Import the loggable library

To import loggable library, add the following to the Swift source file.
```swift
import Loggable
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

