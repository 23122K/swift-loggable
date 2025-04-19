import SwiftSyntax
import SwiftSyntaxMacros

extension MemberAttributeMacro {
  static func attriibutes(
    @SyntaxBuilder<AttributeSyntax> _ components: () -> [AttributeSyntax] = { [] }
  ) -> [AttributeSyntax] {
    components()
  }
}
