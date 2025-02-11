@attached(memberAttribute)
public macro Logged(using loggable: Loggable = .default) = #externalMacro(
  module: "LoggableMacro",
  type: "LoggedMacro"
)

@attached(body)
public macro Log(using loggable: Loggable = .default) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

@attached(body)
public macro Omit() = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)
