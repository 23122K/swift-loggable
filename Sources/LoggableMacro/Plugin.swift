import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LoggablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LogMacro.self,
    LoggedMacro.self,
    OSLog.self,
    OSLogged.self,
    LevelMacro.self,
    OmitMacro.self,
    TagMacro.self
  ]
}
