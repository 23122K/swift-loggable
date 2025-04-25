import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

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
