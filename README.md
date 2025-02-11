# Loggable
---
Swift macro that eliminates boilerplate when it comes to logging functions. Allows for function logging in any Class, Actor, Struct, or Enum and supports per-function logging while letting you ignore specific functions. The macro handles static, throwing, async, and generic functions with standard arguments as well as inout arguments, closures, and `@autoclosures`. Furthermore, it doesn’t tie you to any underlying logging mechanism, so you can easily implement your own logic.

---
#### Motivation 
Just like any other macro, my main motivation was to eliminate the boilerplate involved in logging functions, especially those found in legacy modules, crafted by ancient programmers in a singelton pattern. Additionally, I didn’t want to restrict anyone to logging mechanism of my choice so `Loggable` has been designed to allow you to implement the logging mechanism that best suits your project, whether it’s Sentry, swift-log, or any other logging library.

---
#### Usage
There are three macros: `@Logged`, `@Log`, and `@Omit`. Both `@Logged` and `@Log` let you specify a class that inherits from `Loggable` to provide your own implementation, while `@Omit` is used to disable logging for that function.

`@Logged` can be attach to, for example, a class. When applied, it automatically annotates every function inside that class with `@Log`. The `@Logged` macro also lets you specify which underlying logging logic should be invoked when a function is called. By default, it uses the `default` parameter, which utilizes `os_log` for logging. You can override this behavior by inheriting from the `Loggable` class and providing a custom argument to the `@Logged` macro, for example:
```swift
@Logged(using: .custom)
```
Where `.custom` in this example would be a an extension to `Loggable` class.

Providing a custom argument to `@Logged` automatically propagates it to every function within its scope. If you want to exclude a specific function from logging, simply annotate it with `@Omit`. Contrarily, if you need a different logging mechanism for a function within that scope or just want to log a single function, you can annotate that function with `@Log` which also allows you to specify your desired logging mechanism.

As of now, there are three methods for you to override:
```swift
open func log(location: String, of declaration: String)
```
This method is invoked when the function neither returns a value nor throws an error.

```swift
open func log(at location: String, of declaration: String, error: any Error)
```
When a function is marked with the `throw` keyword, regardless of whether it returns a value or not, this method will be called.

```swift
open func log(at location: String, of declaration: String, result: Any)
```
Finally, when a function specifies a return value, this method is invoked.

---
#### Future directions 
I’m not entirely sure that using `Loggable` as a class is the best solution, but it does allow for a nicer syntax like `@Log(using: .custom)`, rather than requiring you to specify an implicit type as you would with a protocol. Additionally, although I’m not completely sure how solid this approach is, the default implementation can be overridden or more precisely, shadowed:
```swift
extension Loggable {
  static let `default` = SomeCustomLogger()
}
```
This approach allows us to swap the default logic used by `@Log` and `@Logged` without needing to pass a parameter. Additionally, I’d like to add logging for the parameters passed to a function. However, I foresee potential issues - such as when a closure is passed, which would need to be computed first. If you have any suggestions, please let me know 😉
