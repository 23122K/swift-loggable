import SwiftDiagnostics
import SwiftSyntax

public struct OmitMacro {
  struct Message: DiagnosticMessage {
    var message: String {
      "@Omit macro that specifies traits must preceed @Log or @OSLog declarations"
    }

    var diagnosticID: MessageID {
      MessageID(domain: "OmitMacro", id: "1")
    }

    var severity: DiagnosticSeverity {
      DiagnosticSeverity.error
    }
  }
}
