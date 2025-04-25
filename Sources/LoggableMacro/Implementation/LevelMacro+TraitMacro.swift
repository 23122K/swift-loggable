import SwiftSyntaxMacros
import SwiftDiagnostics

extension LevelMacro: TraitMacro {
  static let message: any DiagnosticMessage = Message()
}
