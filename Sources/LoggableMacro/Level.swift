import SwiftDiagnostics
import SwiftSyntaxMacros

public struct LevelMacro: TraitMacro {
  public static func message() -> any DiagnosticMessage {
    Exception()
  }
}

extension LevelMacro {
  struct Exception: DiagnosticMessage {
    var message: String {
      "@Level macro that specifies traits must preceed @Log or @OSLog declarations"
    }

    var diagnosticID: MessageID {
      MessageID(domain: "OmitMacro", id: "1")
    }

    var severity: DiagnosticSeverity {
      DiagnosticSeverity.error
    }
  }
}
