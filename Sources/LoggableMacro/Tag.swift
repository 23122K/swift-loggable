import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct TagMacro: TraitMacro {
  public static func message() -> any DiagnosticMessage {
    Exception()
  }
}

extension TagMacro {
  struct Exception: DiagnosticMessage {
    var message: String {
      "@Tag macro that specifies traits must preceed @Log or @OSLog declarations."
    }

    var diagnosticID: MessageID {
      MessageID(domain: "OmitMacro", id: "1")
    }

    var severity: DiagnosticSeverity {
      DiagnosticSeverity.error
    }
  }

  static let exception = Exception()
}
