import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension OmitMacro: TraitMacro {
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
