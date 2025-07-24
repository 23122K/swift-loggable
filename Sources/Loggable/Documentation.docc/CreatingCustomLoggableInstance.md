# Defining custom Loggable instance

Define custom Loggable instance and use it with macros.

## Overview

This article focuses on creation of custom Loggable instance, the core feature. 
To showcase 

### Import the loggable library

To import loggable library, add the following to the Swift source file.
```swift
import Loggable
```

### Extend Loggable 

Create an extension to Loggable, this allows for cleaner syntax.

```swift
extension Loggable where Self == LoggingLogger {
  static var logging: any Loggable {
    LoggingLogger(label: "wip")
  }
}
```

> Warning:
> When creating an extension, always use `any Loggable` as a type, otherwise `@Logged` macro will not work.
