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
    guard let member = FunctionDeclSyntax(member),
          !member.attributes.contains(where: \.isLogOrOmitWithoutArgument)
    else { return [] }

//    context.diagnose(
//      .init(node: node, message: ._debug(member.debugDescription))
//    )

    return [AttributeSyntax.copy(node)]
  }
}
