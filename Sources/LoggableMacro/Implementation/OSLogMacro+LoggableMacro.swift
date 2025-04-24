import SwiftSyntax
import SwiftDiagnostics
import LoggableCore

extension OSLogMacro: LoggableMacro {
  static func initialize(for node: AttributeSyntax) -> ExprSyntax {
    ExprSyntax(
      MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
        declName: DeclReferenceExprSyntax(baseName: .predefined(.logger))
      )
    )
  }
}
