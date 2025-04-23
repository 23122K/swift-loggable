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

    if
      let function = FunctionDeclSyntax(member),
      function.attributes.contains(where: \.isLogOrOmitWithoutArgument)
    {
      return self.attriibutes()
    }

    return attriibutes {
      AttributeSyntax.copy(node)
    }
  }
}
