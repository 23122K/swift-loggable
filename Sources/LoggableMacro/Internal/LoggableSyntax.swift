import Foundation
import SwiftSyntax

struct LoggableSyntax {
  let expression: any ExprSyntaxProtocol
  
  enum ExprSyntaxType: Equatable {
    case stringLiteral(String)
    case declReference(TokenSyntax)
    
    var exprSytnaxProtocol: ExprSyntaxProtocol {
      switch self {
      case let .stringLiteral(content):
        return StringLiteralExprSyntax(content: content)
        
      case let .declReference(baseName):
        return DeclReferenceExprSyntax(baseName: baseName)
      }
    }
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
