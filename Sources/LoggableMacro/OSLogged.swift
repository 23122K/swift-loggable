import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import OSLog

public struct OSLogged: MemberMacro, MemberAttributeMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // TODO: 23122K - Find out if it is possible to get info that `OSLogged` has already
    // TODO: been attached to declaration extension
    // Create protocol that will inform as about it?

    let subsystem = node.extract(
      argument: .subsystem,
      as: StringLiteralExprSyntax.self
    )

    let category = node.extract(
      argument: .category,
      as: StringLiteralExprSyntax.self
    )

    let fallbackSubsystem = InfixOperatorExprSyntax(
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


    let fallbackCategory = switch DeclSyntax(declaration).as(DeclSyntaxEnum.self) {
    case let .actorDecl(syntax):
      StringLiteralExprSyntax(content: syntax.name.text)

    case let .classDecl(syntax):
      StringLiteralExprSyntax(content: syntax.name.text)

    case let .enumDecl(syntax):
      StringLiteralExprSyntax(content: syntax.name.text)

    case let .structDecl(syntax):
      StringLiteralExprSyntax(content: syntax.name.text)

    case let .extensionDecl(syntax):
      StringLiteralExprSyntax(content: syntax.extendedType.description)

    default:
      preconditionFailure("")
    }

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
              identifier: .identifier("logger")
            ),
            initializer: InitializerClauseSyntax(
              value: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: .identifier("Logger")
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax {
                  LabeledExprSyntax(
                    label: .identifier("subsystem"),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: subsystem ?? fallbackSubsystem)
                  )
                  LabeledExprSyntax(
                    label: .identifier("category"),
                    colon: .colonToken(),
                    expression: ExprSyntax(fromProtocol: category ?? fallbackCategory)
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

  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    if
      let function = FunctionDeclSyntax(member),
      function.attributes.contains { $0.is(.OSLog) }
    {
      return self.attriibutes()
    }

    return attriibutes {
      AttributeSyntax(
        TypeSyntax(
          IdentifierTypeSyntax(name: .identifier("OSLog()"))
        )
      )
    }
  }
}
