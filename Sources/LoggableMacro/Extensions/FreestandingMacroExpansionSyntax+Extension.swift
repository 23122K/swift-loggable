import SwiftSyntax
import SwiftSyntaxMacros

extension FreestandingMacroExpansionSyntax {
  func extract<T: ExprSyntaxProtocol>(
    argument label: TokenKind.Predefined,
    as type: T.Type
  ) -> T? {
    self.arguments
      .first { argument in argument.label?.tokenKind == label.identifier }?
      .expression
      .as(type)
  }
}
