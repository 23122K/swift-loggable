import SwiftSyntax
import SwiftSyntaxMacros

extension OSLoggedMacro: LoggableAttributeMacro {
  static func ignore(_ attribute: AttributeSyntax) -> Bool {
    guard let identifierType =  IdentifierTypeSyntax(attribute.attributeName) else {
      return false
    }

    switch identifierType.name.tokenKind {
    case .predefined(.OSLog):
      return true

    case .predefined(.Omit) where attribute.arguments == nil:
      return true

    default:
      return false
    }
  }

  static func introduce(for node: AttributeSyntax) -> AttributeSyntax {
    AttributeSyntax(
      TypeSyntax(
        IdentifierTypeSyntax(name: .predefined(.OSLog))
      )
    )
  }
}
