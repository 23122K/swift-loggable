import Foundation
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftSyntax

struct MacroBuilder {
  protocol Body: BodyMacro {
    static func expansion(
      of node: AttributeSyntax,
      for function: FunctionSyntax,
      in context: some MacroExpansionContext,
      using loggable: LoggableSyntax
    ) -> [CodeBlockItemSyntax]
  }

  protocol MemberAttribute: MemberAttributeMacro {
    static func expansion(
      of node: AttributeSyntax,
      for function: FunctionDeclSyntax
    ) -> [AttributeSyntax]
  }
}

extension MacroBuilder.Body {
  static func body(
    @SyntaxBuilder<CodeBlockItemSyntax> _ components: () -> [CodeBlockItemSyntax] = { [] }
  ) -> [CodeBlockItemSyntax] {
    components()
  }

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let location = context.location(of: node)?.findable else { return self.body() }
    let loggable = LoggableSyntax(for: node.loggable, in: location)
    return body {
      if let function = FunctionSyntax(from: declaration) {
        self.expansion(
          of: node,
          for: function,
          in: context,
          using: loggable
        )
      }
    }
  }
}

extension MacroBuilder.MemberAttribute {
  static func attriibutes(
    @SyntaxBuilder<AttributeSyntax> _ components: () -> [AttributeSyntax] = { [] }
  ) -> [AttributeSyntax] {
    components()
  }

  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    return attriibutes {
      if let functionDeclSyntax = FunctionDeclSyntax(member) {
        self.expansion(
          of: node,
          for: functionDeclSyntax
        )
      }
    }
  }
}

@resultBuilder
struct SyntaxBuilder<T> {
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
