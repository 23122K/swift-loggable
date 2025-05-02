import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

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
