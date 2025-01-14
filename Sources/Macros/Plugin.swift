import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct LoggablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LogMacro.self,
    LoggedMacro.self,
    OmitMacro.self
  ]
}
