import SwiftSyntax

extension AttributeListSyntax.Element {
  var isOmit: Bool {
    switch self {
    case let .attribute(attribute):
      guard let syntax = IdentifierTypeSyntax(attribute.attributeName)
      else { fallthrough }
      return syntax.name.tokenKind == .omit
      
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
