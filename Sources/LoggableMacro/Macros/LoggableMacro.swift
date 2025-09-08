import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

protocol LoggableMacro: BodyMacro {
  static func initialize(for node: AttributeSyntax) -> ExprSyntax
}

extension LoggableMacro {
  public static func initialize(for node: AttributeSyntax) -> ExprSyntax {
    guard let expression = node.extract(
      argument: TokenKind.parameter(.using),
      as: ExprSyntax.self
    ) else {
      return ExprSyntax(
        MemberAccessExprSyntax(
          name: TokenSyntax.variable(.logger)
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

    let tagTraits = function.syntax.attributes.extractTraits(for: .tag)
    let omitTraits = function.syntax.attributes.extractTraits(for: .omit)
    let levelTrait = function.syntax.attributes.extractTraits(for: .level).first

    return body {
      self.hook(for: node)
      self.event(
        for: node,
        in: context,
        of: function,
        levelTrait: levelTrait,
        taggableTraits: tagTraits,
        omittableTraits: omitTraits
      )

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
          if !omitTraits.contains(where: \.isOmitResult) {
            self.capture(.result)
          }
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
        bindingSpecifier: TokenSyntax.keyword(.let),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: TokenSyntax.variable(.loggable)
            ),
            typeAnnotation: TypeAnnotationSyntax(
              type: SomeOrAnyTypeSyntax(
                someOrAnySpecifier: TokenSyntax.keyword(.any),
                constraint: IdentifierTypeSyntax(
                  name: TokenSyntax.conformance(.Loggable)
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
    of declaration: FunctionSyntax,
    levelTrait: (any ExprSyntaxProtocol)?,
    taggableTraits: [any ExprSyntaxProtocol],
    omittableTraits: [any ExprSyntaxProtocol]
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: TokenSyntax.keyword(
          declaration.isThrowing || !(declaration.isVoid || omittableTraits.contains(where: \.isOmitResult))
            ? .var
            : .let
        ),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: TokenSyntax.variable(.event)
            ),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: TokenSyntax.type(.LoggableEvent)
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  // MARK: - level: (any Levelable)?
                  if let level = levelTrait {
                    LabeledExprSyntax(
                      leadingTrivia: Trivia.newline,
                      label: TokenSyntax.parameter(.level),
                      colon: TokenSyntax.colonToken(),
                      expression: level,
                      trailingComma: TokenSyntax.commaToken()
                    )
                  }

                  // MARK: - location: String
                  LabeledExprSyntax(
                    leadingTrivia: Trivia.newline,
                    label: TokenSyntax.parameter(.location),
                    colon: TokenSyntax.colonToken(),
                    expression: self.location(
                      of: declaration,
                      in: context
                    ),
                    trailingComma: TokenSyntax.commaToken(),
                    trailingTrivia: Trivia.newline
                  )

                  // MARK: - declaration: String
                  LabeledExprSyntax(
                    label: TokenSyntax.parameter(.declaration),
                    colon: TokenSyntax.colonToken(),
                    expression: StringLiteralExprSyntax(content: declaration.description),
                    trailingComma: TokenSyntax.commaToken(),
                    trailingTrivia: Trivia.newline
                  )

                  // MARK: - parameters: [String: LoggableMetadata]
                  if !omittableTraits.contains(where: \.isOmitParameters) {
                    LabeledExprSyntax(
                      label: TokenSyntax.parameter(.parameters),
                      colon: TokenSyntax.colonToken(),
                      expression: DictionaryExprSyntax(
                        leftSquare: .leftSquareToken(
                          trailingTrivia: declaration.parameters.isEmpty ? [] : Trivia.newline
                        ),
                        rightSquare: .rightSquareToken(
                          leadingTrivia: declaration.parameters.isEmpty ? [] : Trivia.newline
                        )
                      ) {
                        DictionaryElementListSyntax {
                          declaration.parameters.compactMap { parameter in
                            // TODO: 23122K - Is there a better way to handle it?
                            if omittableTraits.contains(
                              where: { trait in trait.isOmitParameter(parameter.name) }
                            ) { return nil }
                            
                            return DictionaryElementSyntax(
                              key: StringLiteralExprSyntax(content: parameter.name.text),
                              value: FunctionCallExprSyntax(
                                calledExpression: DeclReferenceExprSyntax(
                                  baseName: TokenSyntax.type(.String)
                                ),
                                leftParen: TokenSyntax.leftParenToken(),
                                arguments: LabeledExprListSyntax {
                                  LabeledExprSyntax(
                                    label: TokenSyntax.parameter(.reflecting),
                                    colon: TokenSyntax.colonToken(),
                                    expression: DeclReferenceExprSyntax(
                                      baseName: parameter.name.trimmed
                                    )
                                  )
                                },
                                rightParen: TokenSyntax.rightParenToken()
                              ),
                              trailingComma: .commaToken(
                                presence: declaration.parameters.last == parameter ? .missing : .present
                              ),
                              trailingTrivia: Trivia.newline
                            )
                          }
                        }
                      },
                      trailingComma: TokenSyntax.commaToken(),
                      trailingTrivia: Trivia.newline
                    )
                  }

                  // MARK: - Tags
                  LabeledExprSyntax(
                    label: TokenSyntax.parameter(.tags),
                    colon: TokenSyntax.colonToken(),
                    expression: ArrayExprSyntax(
                      elements: ArrayElementListSyntax {
                        taggableTraits.map { trait in
                          ArrayElementSyntax(expression: trait)
                        }
                      }
                    ),
                    trailingTrivia: Trivia.newline
                  )
                },
                rightParen: TokenSyntax.rightParenToken()
              )
            )
          )
        )
      )
    )
  }

  static func capture(
    _ baseName: LoggableMacroTokens.Variable
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      InfixOperatorExprSyntax(
        leftOperand: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: TokenSyntax.variable(.event)
          ),
          name: TokenSyntax.variable(.result)
        ),
        operator: AssignmentExprSyntax(),
        rightOperand: FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(
            name: TokenSyntax.variable(baseName == .result ? .success : .failure)
          ),
          leftParen: .leftParenToken(),
          arguments: LabeledExprListSyntax {
            if baseName == LoggableMacroTokens.Variable.error {
              LabeledExprSyntax(
                expression: DeclReferenceExprSyntax(
                  baseName: TokenSyntax.variable(baseName)
                )
              )
            } else {
              LabeledExprSyntax(
                expression: FunctionCallExprSyntax(
                  calledExpression: DeclReferenceExprSyntax(
                    baseName: TokenSyntax.type(.String)
                  ),
                  leftParen: TokenSyntax.leftParenToken(),
                  arguments: LabeledExprListSyntax {
                    LabeledExprSyntax(
                      label: TokenSyntax.parameter(.reflecting),
                      colon: TokenSyntax.colonToken(),
                      expression: DeclReferenceExprSyntax(
                        baseName: TokenSyntax.variable(baseName)
                      )
                    )
                  },
                  rightParen: TokenSyntax.rightParenToken()
                )
              )
            }
          },
          rightParen: TokenSyntax.rightParenToken()
        )
      )
    )
  }

  static func emit() -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: TokenSyntax.variable(.loggable)
          ),
          period: .periodToken(),
          name: TokenSyntax.function(.emit)
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arrayLiteral: LabeledExprSyntax(
            label: TokenSyntax.variable(.event),
            colon: TokenSyntax.colonToken(),
            expression: DeclReferenceExprSyntax(
              baseName: TokenSyntax.variable(.event)
            )
          )
        ),
        rightParen: TokenSyntax.rightParenToken()
      )
    )
  }
}
