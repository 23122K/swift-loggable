import SwiftSyntaxMacros
import SwiftDiagnostics

extension LevelMacro: TraitMacro {
  public static func message() -> any DiagnosticMessage {
    Exception()
  }
}
