import Foundation
import LoggableCore
import SwiftSyntax

public struct LoggableSyntax {
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
}

extension LoggableSyntax.ArgumentSyntax {
  static let error = LoggableSyntax.ArgumentSyntax(
    label: .predefined(.result),
    expression: .functionCall(.predefined(.error), success: false)
  )

  static let result = LoggableSyntax.ArgumentSyntax(
    label: .predefined(.result),
    expression: .functionCall(.predefined(.result), success: true)
  )

  static func parameters(
    @ResultBuilder<FunctionSyntax.Signature.Parameter>  _ elements: () -> [FunctionSyntax.Signature.Parameter]
  ) -> LoggableSyntax.ArgumentSyntax {
    LoggableSyntax.ArgumentSyntax(
      label: .predefined(.parameters),
      expression: .dictionary(elements().map(\.name))
    )
  }
}
