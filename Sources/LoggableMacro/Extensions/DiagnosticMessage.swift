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
    _ message: Any,
    severity: DiagnosticSeverity = .error
  ) -> Self {
    DebugDiagnostic(
      message: String(reflecting: message),
      severity: severity
    )
  }
}
