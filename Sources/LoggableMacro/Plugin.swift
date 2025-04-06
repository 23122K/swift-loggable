import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LoggablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LogMacro.self,
    LoggedMacro.self,
    OmitMacro.self,
    TagMacro.self
  ]
}
