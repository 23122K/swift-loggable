import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension TagMacro: TraitMacro {
  static let message: any DiagnosticMessage = Message()
}
