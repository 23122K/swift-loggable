import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import LoggableCore

public struct OSLog: LoggableMacro {
  static func initialize(for node: AttributeSyntax) -> ExprSyntax {
    ExprSyntax(
      MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
        declName: DeclReferenceExprSyntax(baseName: .predefined(.logger))
      )
    )
  }
}
