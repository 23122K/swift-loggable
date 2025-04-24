@_exported public import LoggableCore

@attached(member, names: named(logger))
@attached(memberAttribute)
public macro OSLogged(
  subsystem: String? = nil,
  category: String? = nil
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLoggedMacro"
)

@attached(body)
public macro OSLog(
  level: (any Levelable)? = nil,
  omit: any Ommitable... = [],
  tag: any Taggable... = []
) = #externalMacro(
  module: "LoggableMacro",
  type: "OSLogMacro"
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
  level: (any Levelable)? = nil,
  omit: any Ommitable... = [],
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
public macro Omit(_ traits: any Ommitable... = []) = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Tag(_ traits: any Taggable...) =  #externalMacro(
  module: "LoggableMacro",
  type: "TagMacro"
)
