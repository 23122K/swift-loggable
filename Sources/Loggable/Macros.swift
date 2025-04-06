@_exported public import LoggableCore

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
  omit: any Ommitable...
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
public macro Tag(_ tag: any Taggable...) =  #externalMacro(
  module: "LoggableMacro",
  type: "TagMacro"
)
