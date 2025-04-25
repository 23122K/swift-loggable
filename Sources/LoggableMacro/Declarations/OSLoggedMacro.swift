import SwiftSyntax
import SwiftDiagnostics

public struct OSLoggedMacro {
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
}
