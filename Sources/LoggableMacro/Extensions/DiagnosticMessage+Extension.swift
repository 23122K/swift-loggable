import SwiftDiagnostics

struct DebugDiagnostic: DiagnosticMessage {
  var message: String
  var severity: DiagnosticSeverity

  var diagnosticID: MessageID {
    MessageID(
      domain: "Loggable",
      id: "-"
    )
  }
}

extension DiagnosticMessage where Self == DebugDiagnostic {
  static func debug(
    _ message: String,
    severity: DiagnosticSeverity = .error
  ) -> Self {
    DebugDiagnostic(
      message: message,
      severity: severity
    )
  }
}
