import SwiftDiagnostics
import SwiftSyntaxMacros

extension LevelMacro: TraitMacro {
  static let message: any DiagnosticMessage = Message()
}
