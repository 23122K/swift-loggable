import SwiftDiagnostics
import SwiftSyntax

public struct TagMacro {
  struct Message: DiagnosticMessage {
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
}
