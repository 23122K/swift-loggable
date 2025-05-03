import LoggableCore
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

protocol LoggableMacro: BodyMacro {
  static func initialize(for node: AttributeSyntax) -> ExprSyntax
}

extension LoggableMacro {
  public static func initialize(for node: AttributeSyntax) -> ExprSyntax {
    guard let expression = node.extract(argument: .using, as: ExprSyntax.self) else {
      return ExprSyntax(
        MemberAccessExprSyntax(
          name: .predefined(.logger)
        )
      )
    }
    return expression
  }

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let function = FunctionSyntax(from: declaration)
    else { return self.body() }

    return body {
      self.hook(for: node)
      self.event(for: node, in: context, of: function)

      if function.parameters.isEmpty || function.traits.ommitable.contains(.parameters) {
        self.body()
      } else {
        self.capture(
          .parameters {
            function.parameters.compactMap { parameter in
              return function.traits.ommitable.contains(.parameter(parameter.name.text))
                ? nil
                : parameter
            }
          }
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

      case false where function.traits.ommitable.contains(.result):
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
        self.emit()
        CodeBlockItemSyntax.return

      case false:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
        self.capture(.result)
        self.emit()
        CodeBlockItemSyntax.return
      }
    }
  }

  static func location(
    of function: FunctionSyntax,
    in context: some MacroExpansionContext
  ) -> StringLiteralExprSyntax {
    StringLiteralExprSyntax(
      content: context.location(of: function.syntax)?.findable ?? ""
    )
  }

  static func hook(
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
                constraint: IdentifierTypeSyntax(
                  name: .predefined(.Loggable)
                )
              )
            ),
            initializer: InitializerClauseSyntax(
              value: self.initialize(for: node)
            )
          )
        )
      )
    )
  }

  static func event(
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
                  if let level = declaration.traits.level {
                    LabeledExprSyntax(
                      leadingTrivia: .newline,
                      label: .identifier("level"),
                      colon: .colonToken(),
                      expression: StringLiteralExprSyntax(
                        content: level.rawValue
                      ),
                      trailingComma: .commaToken(),
                      trailingTrivia: .newline
                    )
                  }
                  LabeledExprSyntax(
                    label: .predefined(.location),
                    colon: .colonToken(),
                    expression: self.location(
                      of: declaration,
                      in: context
                    ),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )
                  LabeledExprSyntax(
                    label: .predefined(.declaration),
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(content: declaration.description),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )
                  LabeledExprSyntax(
                    label: .predefined(.tags),
                    colon: .colonToken(),
                    expression: ArrayExprSyntax(
                      elements: ArrayElementListSyntax {
                        declaration.traits.taggable.map { tag in
                          ArrayElementSyntax(
                            expression: StringLiteralExprSyntax(
                              content: tag.rawValue
                            )
                          )
                        }
                      }
                    ),
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
    CodeBlockItemSyntax(
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
