import Foundation
import SwiftSyntax

struct LoggableSyntax {
  let expression: any ExprSyntaxProtocol

  enum ExprSyntaxType: Equatable {
    case stringLiteral(String)
    case declReference(TokenSyntax)
    case array([TokenSyntax])

    var exprSytnaxProtocol: ExprSyntaxProtocol {
      switch self {
      case let .stringLiteral(content):
        return StringLiteralExprSyntax(content: content)

      case let .declReference(baseName):
        return DeclReferenceExprSyntax(baseName: baseName)
        
      case let .array(elements):
        return ArrayExprSyntax(
          elements: ArrayElementListSyntax(
            elements.map { element in
              ArrayElementSyntax(
                expression: DeclReferenceExprSyntax(baseName: element),
                trailingComma: .commaToken(
                  presence: elements.last == element
                    ? .missing
                    : .present
                )
              )
            }
          )
        )
      }
    }
  }

  func event(at location: String, for declaration: FunctionSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.var),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier("event")),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                  base: DeclReferenceExprSyntax(baseName: .Loggable),
                  name: .identifier("Event")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax(
                    [
                      LabeledExprSyntax(
                      label: "location",
                      colon: .colonToken(),
                      expression: StringLiteralExprSyntax(content: location),
                      trailingComma: .commaToken()
                    ),
                    LabeledExprSyntax(
                      label: "declaration",
                      colon: .colonToken(),
                      expression: StringLiteralExprSyntax(content: declaration.description)
                    )
                  ]
                ),
                rightParen: .rightParenToken()
              )
            )
          )
        )
      )
    )
  }

  func capture(_ name: TokenSyntax, result expression: ExprSyntaxType) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      InfixOperatorExprSyntax(
        leftOperand: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(baseName: .identifier("event")),
          name: name
        ),
        operator: AssignmentExprSyntax(),
        rightOperand: expression.exprSytnaxProtocol
      )
    )
  }

  var emit: CodeBlockItemSyntax {
    CodeBlockItemSyntax (
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: ExprSyntax(expression),
          period: .periodToken(),
          name: .identifier("emit")
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arrayLiteral: LabeledExprSyntax(
            label: .identifier("event"),
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: .identifier("event"))
          )
        ),
        rightParen: .rightParenToken()
      )
    )
  }

  struct ArgumentSyntax: Equatable {
    let label: TokenSyntax
    let expression: ExprSyntaxType

    func labeledExprSyntax(comma presence: SourcePresence) -> LabeledExprSyntax {
      LabeledExprSyntax(
        label: label,
        colon: .colonToken(),
        expression: expression.exprSytnaxProtocol,
        trailingComma: .commaToken(presence: presence)
      )
    }

    private init(label: TokenSyntax, expression: ExprSyntaxType) {
      self.label = label
      self.expression = expression
    }
    
    init(_ label: TokenSyntax, reference elements: [TokenSyntax]) {
      self.init(
        label: label,
        expression: .array(elements)
      )
    }

    init(_ label: TokenSyntax, reference syntax: TokenSyntax) {
      self.init(
        label: label,
        expression: .declReference(syntax)
      )
    }

    init(_ label: TokenSyntax, content: String) {
      self.init(
        label: label,
        expression: .stringLiteral(content)
      )
    }
  }

  @resultBuilder
  struct ArgumentSyntaxBuilder {
    static func buildBlock(_ components: [ArgumentSyntax]...) -> [ArgumentSyntax] {
      components.flatMap { $0 }
    }

    static func buildExpression(_ expression: ArgumentSyntax) -> [ArgumentSyntax] {
      [expression]
    }

    static func buildExpression(_ expression: [ArgumentSyntax]) -> [ArgumentSyntax] {
      expression
    }
  }

  func log(
    @ArgumentSyntaxBuilder _ arguments: () -> [ArgumentSyntax]
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: ExprSyntax(expression),
          period: .periodToken(),
          name: .log
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arguments().map { argument in
            argument.labeledExprSyntax(
              comma: arguments().last == argument
                ? .missing
                : .present
            )
          }
        ),
        rightParen: .rightParenToken()
      )
    )
  }

  init(for expression: some ExprSyntaxProtocol) {
    self.expression = expression
  }
}
