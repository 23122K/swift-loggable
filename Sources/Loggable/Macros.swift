@_exported public import LoggableCore
public import OSLog

@attached(member, names: named(logger))
@attached(memberAttribute)
public macro OSLogged(
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLogged"
)

@attached(body)
public macro OSLog() = #externalMacro(
  module: "LoggableMacro",
  type: "OSLog"
)

@attached(body)
public macro OSLog(level: OSLogType) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLog"
)

@attached(memberAttribute)
public macro Logged(using loggable: any Loggable = .signposter) = #externalMacro(
  module: "LoggableMacro",
  type: "LoggedMacro"
)

@attached(body)
public macro Log(using loggable: any Loggable = .signposter) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

@attached(body)
public macro Log(
  using loggable: any Loggable = .signposter,
  omit: any Ommitable... = [],
  tag: any Taggable... = []
) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

@attached(body)
public macro Omit() = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Omit(_ traits: any Ommitable...) = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Tag(_ traits: any Taggable...) =  #externalMacro(
  module: "LoggableMacro",
  type: "TagMacro"
)
