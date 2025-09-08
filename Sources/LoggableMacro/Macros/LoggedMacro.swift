import SwiftSyntax

public struct LoggedMacro {}

extension LoggedMacro: LoggableAttributeMacro {
  static func ignore(_ attribute: AttributeSyntax) -> Bool {
    guard let identifierType = IdentifierTypeSyntax(attribute.attributeName) else {
      return false
    }

    switch identifierType.name.tokenKind {
    case TokenKind.type(.Log):
      return true

    case TokenKind.type(.Omit) where attribute.arguments == nil:
      return true

    default:
      return false
    }
  }

  static func introduce(for node: AttributeSyntax) -> AttributeSyntax {
    var syntax = node
    syntax.attributeName = TypeSyntax(
      IdentifierTypeSyntax(
        name: TokenSyntax.type(.Log)
      )
    )
    return syntax
  }
}
