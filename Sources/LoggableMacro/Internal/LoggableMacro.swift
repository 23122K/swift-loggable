import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics
import LoggableCore

class Exception {
  var node: AttributeSyntax
  var context: any MacroExpansionContext

  func raise<Message: DiagnosticMessage>(error message: Message) {
    context.diagnose(
      Diagnostic(
        node: node,
        message: message
      )
    )
  }

  init(node: AttributeSyntax, context: MacroExpansionContext) {
    self.node = node
    self.context = context
  }

  nonisolated(unsafe) static var exception: Exception? = nil
}

protocol LoggableMacro: BodyMacro {
  static func delcaration(of node: AttributeSyntax) -> ExprSyntax
  static func tags(from declaration: FunctionDeclSyntax) -> ArrayExprSyntax
}

extension LoggableMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let function = FunctionSyntax(from: declaration)
    else { return self.body() }
    Exception.exception = .init(node: node, context: context)

    return body {
      self.initalize(for: node)
      self.__event(
        for: node,
        in: context,
        of: function
      )

      if !function.parameters.isEmpty && !function.traits.ommitable.contains(where: { $0 == .parameters}) {
        self.capture(
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
        self.emit()

      case true where function.isVoid:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
        } catch: {
          self.capture(.error)
          self.emit()
          CodeBlockItemSyntax.rethrow
        }

      case true:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
          self.capture(.result)
          self.emit()
          CodeBlockItemSyntax.return
        } catch: {
          self.capture(.error)
          self.emit()
          CodeBlockItemSyntax.rethrow
        }

      case false:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
        if !function.traits.ommitable.contains { $0 == .result } {
          self.capture(.result)
        }
        self.emit()
        CodeBlockItemSyntax.return
      }
    }
  }

  static func location(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> StringLiteralExprSyntax {
    StringLiteralExprSyntax(
      content: context.location(of: node)?.findable ?? ""
    )
  }

  static func taggable(from declaration: FunctionDeclSyntax) -> [TaggableTrait] {
    declaration
      .attributes
      .parsableTraitSyntax()
      .taggable
  }

  static func ommitable(from declaration: FunctionDeclSyntax) -> [OmmitableTrait] {
    declaration
      .attributes
      .parsableTraitSyntax()
      .ommitable
  }

  static func initalize(
    for node: AttributeSyntax
  ) -> CodeBlockItemSyntax {
    return CodeBlockItemSyntax(
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
              value: self.delcaration(of: node)
            )
          )
        )
      )
    )
  }

  static func __event(
    for node: AttributeSyntax,
    in context: some MacroExpansionContext,
    of declaration: FunctionSyntax
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.var),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .predefined(.event)),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: .predefined(.LoggableEvent)
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  LabeledExprSyntax(
                    leadingTrivia: .newline,
                    label: .predefined(.location),
                    colon: .colonToken(),
                    expression: self.location(
                      of: node,
                      in: context
                    ),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )
                  LabeledExprSyntax(
                    label: .predefined(.declaration),
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(content: declaration.description),
                    trailingTrivia: .newline
                  )
                  LabeledExprSyntax(
                    label: .predefined(.tags),
                    colon: .colonToken(),
                    expression: self.tags(from: declaration.syntax),
                    trailingTrivia: .newline
                  )
                },
                rightParen: .rightParenToken()
              )
            )
          )
        )
      )
    )
  }

  static func capture(_ argument: LoggableSyntax.ArgumentSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      InfixOperatorExprSyntax(
        leftOperand: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(baseName: .predefined(.event)),
          name: argument.label
        ),
        operator: AssignmentExprSyntax(),
        rightOperand: argument.expression.exprSytnaxProtocol
      )
    )
  }

  static func emit() -> CodeBlockItemSyntax {
    CodeBlockItemSyntax (
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: .predefined(.loggable)
          ),
          period: .periodToken(),
          name: .predefined(.emit)
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arrayLiteral: LabeledExprSyntax(
            label: .predefined(.event),
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: .predefined(.event))
          )
        ),
        rightParen: .rightParenToken()
      )
    )
  }
}
