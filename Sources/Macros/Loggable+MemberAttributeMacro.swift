import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoggedMacro: MemberAttributeMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    guard let member = FunctionDeclSyntax(member)
    else { return [] }
    
    if member.attributes.contains(where: \.isOmit) {
      return []
    }
    
    return [
      node.modify { node in
        node.attributeName = TypeSyntax(
          IdentifierTypeSyntax(name: "Log")
        )
        return node
      }
    ]
  }
}

//extension AttributeSyntax {
//  func has(agruments: )
//}

extension LabeledExprSyntax {
  var usingIdentifier: Bool {
    self.label == .identifier("using")
  }
}

extension AttributeListSyntax.Element {
  var isOmit: Bool {
    switch self {
    case let .attribute(attribute):
      guard let syntax = IdentifierTypeSyntax(attribute.attributeName)
      else { return false }
      return syntax.name.tokenKind == .identifier("Omit")
      
    default:
      return false
    }
  }
}
