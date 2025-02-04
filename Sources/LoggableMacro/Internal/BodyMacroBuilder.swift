import Foundation
import SwiftSyntax

protocol BodyMacroBuilder {
  associatedtype Body
}

extension BodyMacroBuilder where Body == [CodeBlockItemSyntax] {
  static func body(
    @CodeBlockItemSyntaxBuilder _ components: () -> [CodeBlockItemSyntax] = { [] }
  ) -> [CodeBlockItemSyntax] {
    components()
  }
}

@resultBuilder
struct CodeBlockItemSyntaxBuilder {
  static func buildBlock(
    _ components: [CodeBlockItemSyntax]...
  ) -> [CodeBlockItemSyntax] {
    components.flatMap { $0 }
  }
  
  static func buildExpression(
    _ expression: [CodeBlockItemSyntax]
  ) -> [CodeBlockItemSyntax] {
    expression
  }
  
  static func buildExpression(
    _ expression: CodeBlockItemSyntax
  ) -> [CodeBlockItemSyntax] {
    [expression]
  }
  
  static func buildOptional(
    _ component: [CodeBlockItemSyntax]?
  ) -> [CodeBlockItemSyntax] {
    component ?? []
  }
  
  static func buildEither(
    first component: [CodeBlockItemSyntax]
  ) -> [CodeBlockItemSyntax] {
    component
  }
  
  static func buildEither(
    second component: [CodeBlockItemSyntax]
  ) -> [CodeBlockItemSyntax] {
    component
  }
}
