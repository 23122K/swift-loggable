import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

protocol LoggableMacro: BodyMacro {
  static func loggable(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> LoggableSyntax

  static func initalize(_ loggable: LoggableSyntax) -> CodeBlockItemSyntax
}

extension LoggableMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let function = FunctionSyntax(from: declaration)
    else { return self.body() }
    let loggable = self.loggable(of: node, in: context)

    return body {
      self.initalize(loggable)
      loggable.event(for: function, tags: function.traits.taggable)

      if !function.parameters.isEmpty && !function.traits.ommitable.contains(where: { $0 == .parameters}) {
        loggable.capture(
          .parameters(
            function.parameters.compactMap { parameter in
              if !function.traits.ommitable.contains(where: { $0 == .parameter(parameter.name.text) }) {
                return parameter
              }
              return nil
            }
          )
        )
      }

      switch function.isThrowing {
      case false where function.isVoid:
        function.body
        loggable.emit

      case true where function.isVoid:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
        } catch: {
          loggable.capture(.error)
          loggable.emit
          CodeBlockItemSyntax.rethrow
        }

      case true:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
          loggable.capture(.result)
          loggable.emit
          CodeBlockItemSyntax.return
        } catch: {
          loggable.capture(.error)
          loggable.emit
          CodeBlockItemSyntax.rethrow
        }

      case false:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
        if !function.traits.ommitable.contains { $0 == .result } {
          loggable.capture(.result)
        }
        loggable.emit
        CodeBlockItemSyntax.return
      }
    }
  }

  static func _initalize(for expression: ExprSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.let),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: .predefined(.loggable)
            ),
            typeAnnotation: TypeAnnotationSyntax(
              type: SomeOrAnyTypeSyntax(
                someOrAnySpecifier: .keyword(.any),
                constraint:IdentifierTypeSyntax(
                  name: .predefined(.Loggable)
                )
              )
            ),
            initializer: InitializerClauseSyntax(
              value: expression
            )
          )
        )
      )
    )
  }
}

