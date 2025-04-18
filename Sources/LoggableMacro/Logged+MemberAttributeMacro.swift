import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoggedMacro: MacroBuilder.MemberAttribute {
  static func expansion(
    of node: AttributeSyntax,
    for function: FunctionDeclSyntax
  ) -> [SwiftSyntax.AttributeSyntax] {
    return attriibutes {
      if function.attributes.contains(where: \.isLogOrOmitWithoutArgument) {
        AttributeSyntax.copy(node)
      }
    }
  }

}
