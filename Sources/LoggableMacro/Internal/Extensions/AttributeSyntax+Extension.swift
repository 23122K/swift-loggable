import SwiftSyntax

extension AttributeSyntax {
  var loggable: ExprSyntax {
    guard case let .argumentList(arguments) = self.arguments
    else { return Self.fallback() }

    for argument in arguments where argument.label?.tokenKind == .predefined(.using) {
      return argument.expression
    }
    return Self.fallback()
  }

  static func copy(_ syntax: AttributeSyntax) -> AttributeSyntax {
    var syntax = syntax
    syntax.attributeName = TypeSyntax(
      IdentifierTypeSyntax(
        name: .predefined(.Log)
      )
    )
    return syntax
  }

  private static func fallback(
    for declName: DeclReferenceExprSyntax = DeclReferenceExprSyntax(baseName: .predefined(.signposter))
  ) -> ExprSyntax {
    ExprSyntax(declName)
  }
}
