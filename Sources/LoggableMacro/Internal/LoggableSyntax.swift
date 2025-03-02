import Foundation
import SwiftSyntax

struct LoggableSyntax {
  let expression: any ExprSyntaxProtocol

  func event(at location: String, for declaration: FunctionSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.var),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .predefined.event),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                  base: DeclReferenceExprSyntax(baseName: .predefined.Loggable),
                  name: .predefined.Event
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  LabeledExprSyntax(
                    leadingTrivia: .newline,
                    label: .predefined.location,
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(content: location),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                  )
                  LabeledExprSyntax(
                    label: .predefined.declaration,
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(content: declaration.description),
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
          base: DeclReferenceExprSyntax(baseName: .predefined.event),
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
          base: ExprSyntax(expression),
          period: .periodToken(),
          name: .predefined.emit
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arrayLiteral: LabeledExprSyntax(
            label: .predefined.event,
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: .predefined.event)
          )
        ),
        rightParen: .rightParenToken()
      )
    )
  }

  enum ExprSyntaxType: Equatable {
    case stringLiteral(String)
    case declReference(TokenSyntax)
    case dictionary([TokenSyntax])

    var exprSytnaxProtocol: ExprSyntaxProtocol {
      switch self {
      case let .stringLiteral(content):
        return StringLiteralExprSyntax(content: content)

      case let .declReference(baseName):
        return DeclReferenceExprSyntax(baseName: baseName)

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

  init(for expression: some ExprSyntaxProtocol) {
    self.expression = expression
  }
}

extension LoggableSyntax.ArgumentSyntax {
  static let error = LoggableSyntax.ArgumentSyntax(
    label: .predefined.error,
    expression: .declReference(.predefined.error)
  )

  static let result = LoggableSyntax.ArgumentSyntax(
    label: .predefined.result,
    expression: .declReference(.predefined.result)
  )

  static func parameters(
    _ elements: [FunctionSyntax.Signature.Parameter]
  ) -> LoggableSyntax.ArgumentSyntax {
    LoggableSyntax.ArgumentSyntax(
      label: .predefined.parameters,
      expression: .dictionary(elements.map(\.name))
    )
  }
}
