import SwiftSyntax
import SwiftSyntaxMacros

extension FreestandingMacroExpansionSyntax {
  func extract<T: ExprSyntaxProtocol>(
    argument label: TokenKind,
    as type: T.Type
  ) -> T? {
    self.arguments
      .first { argument in argument.label?.tokenKind == label }?
      .expression
      .as(type)
  }
}
