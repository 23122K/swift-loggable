import SwiftSyntax
import SwiftDiagnostics

public struct OSLoggedMacro {
  struct Fallback {
    let subsystem: InfixOperatorExprSyntax
    let category: StringLiteralExprSyntax
  }
}
