import SwiftSyntax
import SwiftSyntaxMacros

@resultBuilder
struct SyntaxBuilder<Syntax: SyntaxProtocol> {
  static func buildBlock(
    _ components: [Syntax]...
  ) -> [Syntax] {
    components.flatMap { $0 }
  }

  static func buildExpression(
    _ expression: [Syntax]
  ) -> [Syntax] {
    expression
  }

  static func buildExpression(
    _ expression: Syntax
  ) -> [Syntax] {
    [expression]
  }

  static func buildOptional(
    _ component: [Syntax]?
  ) -> [Syntax] {
    component ?? []
  }

  static func buildEither(
    first component: [Syntax]
  ) -> [Syntax] {
    component
  }

  static func buildEither(
    second component: [Syntax]
  ) -> [Syntax] {
    component
  }

  static func buildArray(_ components: [[Syntax]]) -> [Syntax] {
    components.flatMap { $0 }
  }
}

extension BodyMacro {
  static func body(
    @SyntaxBuilder<CodeBlockItemSyntax> _ components: () -> [CodeBlockItemSyntax] = { [] }
  ) -> [CodeBlockItemSyntax] {
    components()
  }
}

extension MemberAttributeMacro {

}

extension MemberMacro {
  static func members(
    @SyntaxBuilder<VariableDeclSyntax> _ components: () -> [VariableDeclSyntax] = { [] }
  ) -> [DeclSyntax] {
    components()
      .map(DeclSyntax.init)
  }
}

extension MemberAttributeMacro {
  static func attriibutes(
    @SyntaxBuilder<AttributeSyntax> _ components: () -> [AttributeSyntax] = { [] }
  ) -> [AttributeSyntax] {
    components()
  }
}
