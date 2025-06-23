import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct OSLoggerMacro {
  struct Fallback {
    let subsystem: InfixOperatorExprSyntax
    let category: StringLiteralExprSyntax
  }

  enum Message: DiagnosticMessage {
    case OSLoggedMacroNotIsNotSupportedInProtocols

    var message: String {
      switch self {
        case .OSLoggedMacroNotIsNotSupportedInProtocols:
          return "@OSLogged macro is not supported in protocols."
      }
    }

    var diagnosticID: MessageID {
      switch self {
        case .OSLoggedMacroNotIsNotSupportedInProtocols:
          return MessageID(
            domain: "OSLoggedMacro",
            id: "1"
          )
      }
    }

    var severity: DiagnosticSeverity {
      switch self {
        case .OSLoggedMacroNotIsNotSupportedInProtocols:
          return DiagnosticSeverity.error
      }
    }
  }

  static func _category(_ context: some MacroExpansionContext) -> StringLiteralExprSyntax {
    guard let declaration = DeclSyntax(context.lexicalContext.first)
    else { return EmptyStringLiteralExprSyntax() }
    return self.__category(declaration)
  }

  static func _category(_ declaration: some DeclGroupSyntax) -> StringLiteralExprSyntax {
    self.__category(DeclSyntax(declaration))
  }

  static let _subsystem = InfixOperatorExprSyntax(
    leftOperand: MemberAccessExprSyntax(
      base: MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(
          baseName: .predefined(.Bundle)
        ),
        declName: DeclReferenceExprSyntax(
          baseName: .predefined(.main)
        )
      ),
      declName: DeclReferenceExprSyntax(
        baseName: .predefined(.bundleIdentifier)
      )
    ),
    operator: BinaryOperatorExprSyntax(
      operator: .predefined(.doubleQuestionMark)
    ),
    rightOperand: EmptyStringLiteralExprSyntax()
  )

  static func _accessModifier(_ declaration: some DeclGroupSyntax) -> TokenSyntax {
    let declarationAccessModifier = declaration.modifiers
      .map(\.name)
      .first(where: \.isAccessModifier)?
      .tokenKind

    return switch declarationAccessModifier {
      case .keyword(.open):
        TokenSyntax.keyword(.public)

      case .keyword(.final):
        TokenSyntax.keyword(.internal)

      case let .keyword(value):
        TokenSyntax.keyword(value)

      default:
        TokenSyntax.keyword(.internal)
    }
  }

  private static func __category(_ declrataion: DeclSyntax) -> StringLiteralExprSyntax {
    switch declrataion.as(DeclSyntaxEnum.self) {
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
        return EmptyStringLiteralExprSyntax()
    }
  }
}

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

