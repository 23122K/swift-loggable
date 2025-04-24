import SwiftSyntax

extension AttributeSyntax {
  func extract<T: ExprSyntaxProtocol>(
    argument label: TokenKind.Predefined,
    as type: T.Type
  ) -> T? {
    guard case let .argumentList(arguments) = self.arguments
    else { return nil }

    for argument in arguments where argument.label?.tokenKind == label.identifer {
      return T(argument.expression)
    }
    return nil
  }
}
