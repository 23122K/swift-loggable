import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension OSLoggerMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let fallback = Fallback(
      subsystem: self._subsystem,
      category: self._category(context)
    )

    let subsystem = node.extract(argument: .subsystem, as: StringLiteralExprSyntax.self)
    let category = node.extract(argument: .category, as: StringLiteralExprSyntax.self)
    return self.declaration {
      VariableDeclSyntax(
        modifiers: DeclModifierListSyntax {
          DeclModifierSyntax(
            name: .keyword(.static)
          )
        },
        bindingSpecifier: .keyword(.let),
        bindings: PatternBindingListSyntax {
          PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: .predefined(.logger)
            ),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: .predefined(.Logger)
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  LabeledExprSyntax(
                    leadingTrivia: .newline,
                    label: .predefined(.subsystem),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: subsystem ?? fallback.subsystem)
                  )
                  LabeledExprSyntax(
                    leadingTrivia: .newline,
                    label: .predefined(.category),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: category ?? fallback.category),
                    trailingTrivia: .newline
                  )
                },
                rightParen: .rightParenToken()
              )
            )
          )
        }
      )
    }
  }
}
