import SwiftSyntax

extension AttributeListSyntax.Element {
  var isLoggableAttribute: Bool {
    switch self {
    case let .attribute(attribute):
      guard let syntax = IdentifierTypeSyntax(attribute.attributeName)
      else { fallthrough }
      return syntax.name.tokenKind == .predefined(.Omit) || syntax.name.tokenKind == .predefined(.Log)

    default:
      return false
    }
  }

  var isStatic: Bool {
    switch self {
    case let .attribute(attribute):
      guard let syntax = DeclModifierSyntax(attribute.attributeName)
      else { fallthrough }
      return syntax.name.tokenKind == .keyword(.static)

    default:
      return false
    }
  }
}
