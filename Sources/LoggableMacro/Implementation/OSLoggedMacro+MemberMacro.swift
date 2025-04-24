import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import OSLog

extension OSLoggedMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let fallback = try Fallback(
      subsystem: self._subsystem,
      category: self._category(declaration: declaration, in: context)
    )

    let subsystem = node.extract(argument: .subsystem, as: StringLiteralExprSyntax.self)
    let category = node.extract(argument: .category, as: StringLiteralExprSyntax.self)
    return self.members {
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
                    label: .predefined(.subsystem),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: subsystem ?? fallback.category)
                  )
                  LabeledExprSyntax(
                    label: .predefined(.category),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: category ?? fallback.category)
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

  static let _subsystem = InfixOperatorExprSyntax(
    leftOperand: MemberAccessExprSyntax(
      base: MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(
          baseName: .identifier("Bundle")
        ),
        declName: DeclReferenceExprSyntax(
          baseName: .identifier("main")
        )
      ),
      declName: DeclReferenceExprSyntax(
        baseName: .identifier("bundleIdentifier")
      )
    ),
    operator: BinaryOperatorExprSyntax(
      operator: .identifier("??")
    ),
    rightOperand: StringLiteralExprSyntax(content: "")
  )

  static func _category(
    declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> StringLiteralExprSyntax {
    switch DeclSyntax(declaration).as(DeclSyntaxEnum.self) {
    case let .actorDecl(syntax):
      return StringLiteralExprSyntax(content: syntax.name.text)

    case let .classDecl(syntax):
      return StringLiteralExprSyntax(content: syntax.name.text)

    case let .enumDecl(syntax):
      return StringLiteralExprSyntax(content: syntax.name.text)

    case let .structDecl(syntax):
      return StringLiteralExprSyntax(content: syntax.name.text)

    case let .extensionDecl(syntax):
      return StringLiteralExprSyntax(content: syntax.extendedType.description)

    default:
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: .caseOutsideOfSwitchOrEnum
        )
      )
      return StringLiteralExprSyntax(content: "")
    }
  }
}
