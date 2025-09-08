import SwiftDiagnostics
import SwiftSyntax

public struct OSLoggedMacro {}

extension OSLoggedMacro: LoggableAttributeMacro {
  static func ignore(_ attribute: AttributeSyntax) -> Bool {
    guard let identifierType = IdentifierTypeSyntax(attribute.attributeName) else {
      return false
    }

    switch identifierType.name.tokenKind {
    case TokenKind.type(.OSLog):
      return true

    case TokenKind.type(.Omit) where attribute.arguments == nil:
      return true

    default:
      return false
    }
  }

  static func introduce(for node: AttributeSyntax) -> AttributeSyntax {
    AttributeSyntax(
      TypeSyntax(
        IdentifierTypeSyntax(
          name: TokenSyntax.type(.OSLog)
        )
      )
    )
  }
}
