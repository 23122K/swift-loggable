@attached(memberAttribute)
public macro Logged(using loggable: any Loggable.Conformance = .signposter) = #externalMacro(
  module: "LoggableMacro",
  type: "LoggedMacro"
)

@attached(body)
public macro Log(using loggable: any Loggable.Conformance = .signposter) = #externalMacro(
  module: "LoggableMacro",
  type: "LogMacro"
)

@attached(body)
public macro Omit() = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Omit(_ ommitableTraits: any Ommitable...) = #externalMacro(
  module: "LoggableMacro",
  type: "OmitMacro"
)

@attached(body)
public macro Redact(_ redactableTraits: any Redactable...) = #externalMacro(
  module: "LoggableMacro",
  type: "RedactMacro"
)
