import LoggableCore
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LogMacro: LoggableMacro {
  static func delcaration(of node: AttributeSyntax) -> ExprSyntax {
    node.loggable
  }

  static func tags(from declaration: FunctionDeclSyntax) -> ArrayExprSyntax {
    ArrayExprSyntax(
      elements: ArrayElementListSyntax {
        self.taggable(from: declaration).map { tag in
          ArrayElementSyntax(
            expression: StringLiteralExprSyntax(
              content: tag.rawValue
            )
          )
        }
      }
    )
  }
}
