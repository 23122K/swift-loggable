import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct TagMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    context.diagnose(
      Diagnostic(
        node: node,
        message: .tagMacroMustPreceedLogMacro
      )
    )
    return self.body()
  }
}
