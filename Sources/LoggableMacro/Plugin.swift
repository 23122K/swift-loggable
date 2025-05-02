import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct LoggablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LogMacro.self,
    LoggedMacro.self,
    OSLogMacro.self,
    OSLoggerMacro.self,
    OSLoggedMacro.self,
    LevelMacro.self,
    OmitMacro.self,
    TagMacro.self
  ]
}
