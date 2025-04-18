import Foundation
import LoggableCore
import SwiftSyntax

public struct LoggableSyntax {
  let expression: any ExprSyntaxProtocol
  let location: String

  func initialize() -> CodeBlockItemSyntax {
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
              value: DeclReferenceExprSyntax(baseName: .identifier(".signposter"))
            )
          )
        )
      )
    )
  }

  func event(for declaration: FunctionSyntax, tags: [TaggableTrait]) -> CodeBlockItemSyntax {
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
                    expression: StringLiteralExprSyntax(content: self.location),
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
                    expression: ArrayExprSyntax(
                      elements: ArrayElementListSyntax {
                        tags.map { tag in
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

  func capture(_ argument: ArgumentSyntax) -> CodeBlockItemSyntax {
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

  var emit: CodeBlockItemSyntax {
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

  enum ExprSyntaxType: Equatable {
    case stringLiteral(String)
    case functionCall(TokenSyntax, success: Bool)
    case dictionary([TokenSyntax])

    var exprSytnaxProtocol: ExprSyntaxProtocol {
      switch self {
      case let .stringLiteral(content):
        return StringLiteralExprSyntax(content: content)

      case let .functionCall(baseName, success):
        return FunctionCallExprSyntax(
          calledExpression: MemberAccessExprSyntax(
            name: success ? .identifier("success") : .identifier("failure")
          ),
          leftParen: .leftParenToken(),
          arguments: LabeledExprListSyntax {
            LabeledExprSyntax(
              expression: DeclReferenceExprSyntax(baseName: baseName)
            )
          },
          rightParen: .rightParenToken()
        )

      case let .dictionary(elements):
        return DictionaryExprSyntax(
          leftSquare: .leftSquareToken(trailingTrivia: .newline),
          rightSquare: .rightSquareToken(leadingTrivia: .newline)
        ) {
          DictionaryElementListSyntax {
            elements.map { element in
              DictionaryElementSyntax(
                key: StringLiteralExprSyntax(content: element.text),
                value: DeclReferenceExprSyntax(baseName: element.trimmed),
                trailingComma: .commaToken(presence: elements.last == element ? .missing : .present),
                trailingTrivia: .newline
              )
            }
          }
        }
      }
    }
  }

  struct ArgumentSyntax: Equatable {
    let label: TokenSyntax
    let expression: ExprSyntaxType
  }

  init(
    for expression: some ExprSyntaxProtocol,
    in location: String
  ) {
    self.expression = expression
    self.location = location
  }
}

extension LoggableSyntax.ArgumentSyntax {
  static let error = LoggableSyntax.ArgumentSyntax(
    label: .predefined(.error),
    expression: .functionCall(.predefined(.error), success: false)
  )

  static let result = LoggableSyntax.ArgumentSyntax(
    label: .predefined(.result),
    expression: .functionCall(.predefined(.result), success: true)
  )

  static func parameters(
    _ elements: [FunctionSyntax.Signature.Parameter]
  ) -> LoggableSyntax.ArgumentSyntax {
    LoggableSyntax.ArgumentSyntax(
      label: .predefined(.parameters),
      expression: .dictionary(elements.map(\.name))
    )
  }
}
