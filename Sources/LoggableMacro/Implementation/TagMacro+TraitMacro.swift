import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension TagMacro: TraitMacro {
  public static func message() -> any DiagnosticMessage {
    Exception()
  }
}
