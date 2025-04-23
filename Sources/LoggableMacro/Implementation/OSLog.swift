import SwiftSyntax
import SwiftSyntaxMacros

public struct OSLog: LoggableMacro {
  static func delcaration(of node: AttributeSyntax) -> ExprSyntax {
//    self.exception.raise(error: .expectedCommaInWhereClause)

    return ExprSyntax(
      MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
        declName: DeclReferenceExprSyntax(baseName: .predefined(.logger))
      )
    )
  }

  static func tags(from declaration: FunctionDeclSyntax) -> ArrayExprSyntax {
    ArrayExprSyntax(
      elements: ArrayElementListSyntax {})
  }
}

extension OSLog {
  static var exception: Exception {
    Exception.exception!
  }
}
