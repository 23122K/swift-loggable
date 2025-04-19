import SwiftSyntax

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
