import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct OmitMacro: TraitMacro {
  public static func message() -> any DiagnosticMessage {
    Exception()
  }

  public static func expansion(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> [CodeBlockItemSyntax] {
    if let _ = node.arguments {
      context.diagnose(
        Diagnostic(
          node: node,
          message: self.message()
        )
      )
    }
    return self.body()
  }
}

extension OmitMacro {
  struct Exception: DiagnosticMessage {
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
