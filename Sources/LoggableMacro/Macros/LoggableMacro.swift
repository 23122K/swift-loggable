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
            pattern: IdentifierPatternSyntax(identifier: .predefined(.event)),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: .predefined(.LoggableEvent)
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  // MARK: - level: (any Levelable)?
                  if let level = levelTrait {
                    LabeledExprSyntax(
                      leadingTrivia: .newline,
                      label: .predefined(.level),
                      colon: .colonToken(),
                      expression: level,
                      trailingComma: .commaToken()
                    )
                  }

                  // MARK: - location: String
                  LabeledExprSyntax(
                    leadingTrivia: .newline,
                    label: .predefined(.location),
                    colon: .colonToken(),
                    expression: self.location(
                      of: declaration,
                      in: context
                    ),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )

                  // MARK: - declaration: String
                  LabeledExprSyntax(
                    label: .predefined(.declaration),
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(content: declaration.description),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )

                  // MARK: - parameters: [String: Any]
                  if !omittableTraits.contains(where: \.isOmitParameters) {
                    LabeledExprSyntax(
                      label: .predefined(.parameters),
                      colon: .colonToken(),
                      expression: DictionaryExprSyntax(
                        leftSquare: .leftSquareToken(
                          trailingTrivia: declaration.parameters.isEmpty ? [] : .newline
                        ),
                        rightSquare: .rightSquareToken(
                          leadingTrivia: declaration.parameters.isEmpty ? [] : .newline
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
                              value: DeclReferenceExprSyntax(baseName: parameter.name.trimmed),
                              trailingComma: .commaToken(
                                presence: declaration.parameters.last == parameter ? .missing : .present
                              ),
                              trailingTrivia: .newline
                            )
                          }
                        }
                      },
                      trailingComma: .commaToken(),
                      trailingTrivia: .newline
                    )
                  }

                  // MARK: - Tags
                  LabeledExprSyntax(
                    label: .predefined(.tags),
                    colon: .colonToken(),
                    expression: ArrayExprSyntax(
                      elements: ArrayElementListSyntax {
                        taggableTraits.map { trait in
                          ArrayElementSyntax(expression: trait)
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

  static func capture(_ baseName: TokenSyntax.Predefined) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      InfixOperatorExprSyntax(
        leftOperand: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(baseName: .predefined(.event)),
          name: TokenSyntax.predefined(.result)
        ),
        operator: AssignmentExprSyntax(),
        rightOperand: FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(
            name: TokenSyntax.predefined(baseName == .result ? .success : .failure)
          ),
          leftParen: .leftParenToken(),
          arguments: LabeledExprListSyntax {
            LabeledExprSyntax(
              expression: DeclReferenceExprSyntax(baseName: baseName.identifier)
            )
          },
          rightParen: .rightParenToken()
        )
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
