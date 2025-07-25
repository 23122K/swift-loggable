#if canImport(OSLog)
@_exported public import OSLog
#endif
#if canImport(Foundation)
@_exported public import class Foundation.Bundle
#endif

@freestanding(
  declaration,
  names: named(logger)
)
public macro osLogger(
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggerMacro"
)

/// Introduce static instance of Logger object and OSLogger protocol conformance
/// to attached declaration.
///
/// - Parameters:
///   - level: Acess level of Logger instance. Defaults to acess level of attached declaration.
///   - subsystem: A Logger sybsystem to which logs are associated with.
///   - category: The Logger category which logs are associated with.
///
/// - Note: ``OSLogged()`` and ``OSLog(level:omit:tag:)`` depends on this macro.
///
/// This macro is specialized to accomodate Logger usage allowing to override its subsystem, category
/// and access level. Once introduced static instance can be access within declaration as
/// well as is visible for ``OSLogged()`` and ``OSLog(level:omit:tag:)`` macro.
///
/// ```swift
/// @MainActor
/// @OSLogger
/// @Observable
/// public class FooModel {
///   func bar() throws -> Bool {
///     self.logger.info("\(#function)")
///     return Bool.random()
///   }
/// }
/// ```
@attached(
  extension,
  names: named(logger),
  conformances: OSLogger
)
public macro OSLogger(
  access level: AccessLevelModifier? = nil,
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggerMacro"
)

/// Adds ``OSLog(level:omit:tag:)`` macro to all methods within
/// attached declaration. Declaration must confrom to ``OSLogger`` protocol.
///
/// ```swift
/// @OSLogger
/// @OSLogged
/// struct Foo {
///   // ...
/// }
/// ```
///
/// or manualy add conformance to ``OSLogger`` by
/// ```swift
/// @OSLogged
/// struct Bar: OSLogger {
///   static let logger = OSLogger()
///   // ...
/// }
/// ```
@attached(memberAttribute)
public macro OSLogged() = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggedMacro"
)

/// Logs annotated function to Logger instance.
/// Requires conformance to ``OSLogger`` from declaration.
///
/// - Parameters:
///   - level: The logging level to associate with a log.
///   - omit: An infomation that can be omitted upon function capturing.
///   - tag: The tags that can be associated with an event for further processing.
///
/// - Warning: Requires that declaration to which is attached conforms to ``OSLogger``.
@attached(body)
public macro OSLog(
  level: (any Levelable)? = nil,
  omit: any Omittable... = [],
  tag: any Taggable... = []
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLogMacro"
)

/// Introduces ``Log(using:)`` to all methods within attached context.
///
/// - Parameter loggable: The type that handles captured events.
///
/// Annotating declaration with ``Logged(using:)`` will intoduce
/// ``Log(using:)`` macros implicitly to all methods within.
///
/// When  `loggable` parameter is specified, introdcued``Log(using:)``
/// macros will use it. In order to override implicit parameter, we must explicity
/// mark method with ``Log(using:)``
/// ```swift
/// @Logged
/// struct Foo {
///   @Log(using: .nsLog)
///   func bar() async throws {
///     // ...
///   }
///
///   func baz() async -> Qux {
///     // ...
///   }
/// }
/// ```
///
/// To omit methods from being anottated, mark method with ``Omit()``
/// ```swift
/// @Logged
/// enum Foo {
///   static func bar() -> Bool {
///     // Event will be captured upon execution.
///   }
///
///   @Omit
///   static func baz() throws {
///     // Event won't be captured.
///   }
/// }
/// ```
@attached(memberAttribute)
public macro Logged(using loggable: any Loggable = .logger) = #externalMacro(
  module: "LoggableMacro",
  type: "LoggedMacro"
)

/// Logs annotated function and send captured event to a ``Loggable`` instance.
///
/// - Parameter loggable: The type that handles captured events.
@attached(body)
public macro Log(using loggable: any Loggable = .logger) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

/// Logs annotated function and send captured event to a ``Loggable`` instance.
///
/// - Parameters:
///   - loggable: An instance of ``Loggable`` that handles events.
///   - level: The logging level of which event should be emitted.
///   - omit: The information to be omitted when capturing event.
///   - tag: The tags to be associated with captured event.
@attached(body)
public macro Log(
  using loggable: any Loggable = .logger,
  level: (any Levelable)? = nil,
  omit: any Omittable... = [],
  tag: any Taggable... = []
) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

/// Associate logging level to the event emitted from attached function.
///
/// - Parameter trait: The logging level to be associated with an event.
///
/// You can use ``Level(_:)`` and macros that specify ``Levelable`` traits
/// interchengably. E.g. both bellow code snippets will produce the same result.
///
/// ```swift
/// @OSLogger
/// class Foo {
///   @OSLog(level: .fault)
///   func bar() {
///     // ...
///   }
/// }
/// ```
/// ```swift
/// @OSLogger
/// class Foo {
///   @Level(.fault)
///   @OSLog
///   func bar() {
///     // ...
///   }
/// }
/// ```
@attached(body)
public macro Level(_ trait: (any Levelable)? = nil) = #externalMacro(
  module: "LoggableMacro",
  type: "LevelMacro"
)

/// Skips function from being annotated with `Log` or `OSLog` macro.
///
/// ``Logged(using:)`` and ``OSLogged()`` implicitly introduces
/// respectively ``Log(using:)`` and ``OSLog(level:omit:tag:)
/// to all methods within attached context. Mark method with ``Omit()``
/// to skip it.
///
/// ```swift
/// @Logged
/// struct Foo {
///   func bar() -> {
///     // ...
///   }
///
///   @Omit
///   mutating func baz() {
///     // ...
///   }
/// }
/// ```
@attached(body)
public macro Omit() = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

/// Omits some information from when capturing event.
///
/// - Parameter traits: The information to be ommited when creating an event.
///
/// You can use ``Omit(_:)``  and macros that use ``Omittable`` traits
/// interchengably. E.g. both bellow code snippets will produce the same result.
///
/// ```swift
/// class Foo {
///   @Omit(.result)
///   @Log
///   func bar() -> Bar {
///     // ...
///   }
/// }
/// ```
/// ```swift
/// class Foo {
///   @Log(omit: .result)
///   func bar() -> Bar {
///     // ...
///   }
/// }
/// ```
@attached(body)
public macro Omit(_ traits: any Omittable...) = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)


/// Associate tags with captured event.
///
/// - Parameter traits: The tags to be associated with an event.
///
/// You can use ``Tag(_:)``  and macros that use ``Taggable`` traits
/// interchengably. E.g. both bellow code snippets will produce the same result.
///
/// ```swift
/// class Foo {
///   @Tag("Example")
///   @Log
///   func bar() -> Bar {
///     // ...
///   }
/// }
/// ```
/// ```swift
/// class Foo {
///   @Log(tags: "Example")
///   func bar() -> Bar {
///     // ...
///   }
/// }
/// ```
@attached(body)
public macro Tag(_ traits: any Taggable...) =  #externalMacro(
  module: "LoggableMacro",
  type: "TagMacro"
)
