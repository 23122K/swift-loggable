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
    guard let function = FunctionSyntax(from: declaration) else { return self.body() }
    if function.attributes.contains(where: \.isLogMacroPresent) {
      context.diagnose(
        Diagnostic(
          node: node,
          message: .tagMacroMustPreceedLogMacro
        )
      )
    }
    return self.body()
  }
}
