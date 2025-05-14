import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension OSLoggerMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    let fallback = Fallback(
      subsystem: self._subsystem,
      category: self._category(declaration)
    )

    let subsystem = node.extract(argument: .subsystem, as: StringLiteralExprSyntax.self)
    let category = node.extract(argument: .category, as: StringLiteralExprSyntax.self)
    let accessModifier = node.extract(argument: .access, as: MemberAccessExprSyntax.self)
      .flatMap { memberAccessExprSyntax in
        TokenSyntax.identifier(memberAccessExprSyntax.declName.baseName.trimmedDescription)
      }

    let functionCallExprSyntax = FunctionCallExprSyntax(
      calledExpression: DeclReferenceExprSyntax(
        baseName: .predefined(.Logger)
      ),
      leftParen: .leftParenToken(),
      arguments: LabeledExprListSyntax {
        LabeledExprSyntax(
          leadingTrivia: .newline,
          label: .predefined(.subsystem),
          colon: .colonToken(),
          expression: ExprSyntax(
            fromProtocol: subsystem ?? fallback.subsystem
          )
        )
        LabeledExprSyntax(
          leadingTrivia: .newline,
          label: .predefined(.category),
          colon: .colonToken(),
          expression: ExprSyntax(
            fromProtocol: category ?? fallback.category
          ),
          trailingTrivia: .newline
        )
      },
      rightParen: .rightParenToken()
    )

    var patternBindingSyntax = PatternBindingSyntax(
      pattern: IdentifierPatternSyntax(
        identifier: .predefined(.logger)
      ),
      typeAnnotation: TypeAnnotationSyntax(
        type: IdentifierTypeSyntax(
          name: .predefined(.Logger)
        )
      )
    )

    if declaration.isGeneric {
      patternBindingSyntax.accessorBlock = AccessorBlockSyntax(
        accessors: AccessorBlockSyntax.Accessors.getter(
          CodeBlockItemListSyntax {
            CodeBlockItemSyntax(functionCallExprSyntax)
          }
        )
      )
    } else {
      patternBindingSyntax.initializer = InitializerClauseSyntax(value: functionCallExprSyntax)
    }

    return self.conformance {
      ExtensionDeclSyntax(
        extendedType: type,
        inheritanceClause: InheritanceClauseSyntax(
          inheritedTypes: InheritedTypeListSyntax {
            protocols.map { type in
              InheritedTypeSyntax(type: type)
            }
          }
        ),
        memberBlock: MemberBlockSyntax(
          members: MemberBlockItemListSyntax {
            MemberBlockItemSyntax(
              decl: VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                  DeclModifierSyntax(
                    name: .keyword(.nonisolated)
                  )
                  DeclModifierSyntax(
                    name: accessModifier ?? self._accessModifier(declaration)
                  )
                  DeclModifierSyntax(
                    name: .keyword(.static)
                  )
                },
                bindingSpecifier: .keyword(declaration.isGeneric ? .var : .let),
                bindings: PatternBindingListSyntax {
                  patternBindingSyntax
                }
              )
            )
          }
        )
      )
    }
  }
}
