import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

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

extension OmitMacro: TraitMacro {
  static let message: any DiagnosticMessage = Message()

  public static func expansion(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> [CodeBlockItemSyntax] {
    if let _ = node.arguments {
      context.diagnose(
        Diagnostic(
          node: node,
          message: self.message
        )
      )
    }
    return self.body()
  }
}
