@_exported public import LoggableCore
#if canImport(OSLog)
@_exported public import OSLog
#endif
#if canImport(Foundation)
@_exported public import class Foundation.Bundle
#endif

@freestanding(declaration, names: named(logger))
public macro osLogger(
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggerMacro"
)

@attached(extension, names: named(logger), conformances: _OSLogger)
public macro OSLogger(
  access level: _AccessLevelModifier? = nil,
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggerMacro"
)

@attached(memberAttribute)
public macro OSLogged() = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggedMacro"
)

@attached(body)
public macro OSLog(
  level: (any Levelable)? = nil,
  omit: any Omittable... = [],
  tag: any Taggable... = []
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLogMacro"
)

@attached(memberAttribute)
public macro Logged(using loggable: any Loggable = .logger) = #externalMacro(
  module: "LoggableMacro",
  type: "LoggedMacro"
)

@attached(body)
public macro Log(using loggable: any Loggable = .logger) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

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


@attached(body)
public macro Level(_ trait: (any Levelable)? = nil) = #externalMacro(
  module: "LoggableMacro",
  type: "LevelMacro"
)

@attached(body)
public macro Omit(_ traits: any Omittable... = []) = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Tag(_ traits: any Taggable...) =  #externalMacro(
  module: "LoggableMacro",
  type: "TagMacro"
)
