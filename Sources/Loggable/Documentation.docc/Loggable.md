# ``Loggable``

A set of macros that support type-wide and per-function logging with ability to customize how logs are handled.

## Overview
There are many situations where logging additional information can be helpful. However, they are mostly ignored as they come with a lot of boilerplate. This is especially cumbersome in bidirectional architectures. Loggable aims to remove that gap providing macros that can:

* **Annotate all methods within type or extension**

Do not waste time marking each method individualy, simply mark declaration with desired logger and let the magic happen.

* **Customize how logs are handled**

All macros include the ability to add tags to logged functions, suppress their output or parameters, or ecent exclude the functions entirely from emmiting an event.

* **OSLog support**

Loggable provides macros that leverage Apple’s OS framework, forget about creating [`Logger`](https://developer.apple.com/documentation/os/logger) instance, providing it with subsystem, category just to having to log each function individually.

**On top of that**, Loggable does not bind you into any proprietary logging system - use the logger of you choice without compromising on convinence that comes with macros.

## Topics

### Essentials

- <doc:GettingStarted>

### Logged and Log macros

- ``Logged(using:)``
- ``Log(using:)``
- ``Log(using:level:omit:tag:)``

### OSLogger, OSLogged and OSLog macros

- ``OSLogger(access:subsystem:category:)``
- ``OSLogged()``
- ``OSLog(level:omit:tag:)``

### Trait macros

- ``Omit()``
- ``Omit(_:)``
- ``Tag(_:)``
- ``Level(_:)``

### Other macros
- ``osLogger(subsystem:category:)``
