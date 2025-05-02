import SwiftSyntax

extension LoggedMacro: LoggableAttributeMacro {
  static func ignore(_ attribute: AttributeSyntax) -> Bool {
    guard let identifierType = IdentifierTypeSyntax(attribute.attributeName) else {
      return false
    }

    switch identifierType.name.tokenKind {
    case .predefined(.Log):
      return true

    case .predefined(.Omit) where attribute.arguments == nil:
      return true

    default:
      return false
    }
  }

  static func introduce(for node: AttributeSyntax) -> AttributeSyntax {
    var syntax = node
    syntax.attributeName = TypeSyntax(
      IdentifierTypeSyntax(
        name: .predefined(.Log)
      )
    )
    return syntax
  }
}
