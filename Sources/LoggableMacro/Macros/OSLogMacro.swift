import SwiftSyntax

public struct OSLogMacro {}

extension OSLogMacro: LoggableMacro {
  static func initialize(for node: AttributeSyntax) -> ExprSyntax {
    ExprSyntax(
      MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(
          baseName: TokenSyntax.keyword(.Self)
        ),
        declName: DeclReferenceExprSyntax(
          baseName: TokenSyntax.variable(.logger)
        )
      )
    )
  }
}
