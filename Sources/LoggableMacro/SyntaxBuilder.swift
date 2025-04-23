import SwiftSyntax
import SwiftSyntaxMacros

@resultBuilder
struct ResultBuilder<T> {
  static func buildBlock(
    _ components: [T]...
  ) -> [T] {
    components.flatMap { $0 }
  }

  static func buildExpression(
    _ expression: [T]
  ) -> [T] {
    expression
  }

  static func buildExpression(
    _ expression: T
  ) -> [T] {
    [expression]
  }

  static func buildOptional(
    _ component: [T]?
  ) -> [T] {
    component ?? []
  }

  static func buildEither(
    first component: [T]
  ) -> [T] {
    component
  }

  static func buildEither(
    second component: [T]
  ) -> [T] {
    component
  }

  static func buildArray(_ components: [[T]]) -> [T] {
    components.flatMap { $0 }
  }
}

extension BodyMacro {
  static func body(
    @ResultBuilder<CodeBlockItemSyntax> _ components: () -> [CodeBlockItemSyntax] = { [] }
  ) -> [CodeBlockItemSyntax] {
    components()
  }
}

extension MemberMacro {
  static func members(
    @ResultBuilder<VariableDeclSyntax> _ components: () -> [VariableDeclSyntax] = { [] }
  ) -> [DeclSyntax] {
    components()
      .map(DeclSyntax.init)
  }
}

extension MemberAttributeMacro {
  static func attriibutes(
    @ResultBuilder<AttributeSyntax> _ components: () -> [AttributeSyntax] = { [] }
  ) -> [AttributeSyntax] {
    components()
  }
}
