import SwiftSyntax

extension AttributeSyntax {
  func extract<T: ExprSyntaxProtocol>(
    argument label: TokenKind.Predefined,
    as type: T.Type
  ) -> T? {
    guard case let .argumentList(arguments) = self.arguments
    else { return nil }

    return arguments
      .first { argument in argument.label?.tokenKind == label.identifier }?
      .expression
      .as(type)
  }
}
