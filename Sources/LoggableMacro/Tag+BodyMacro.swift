import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public class TagMacro: MacroBuilder.Body {
  public static func expansion(
    of node: AttributeSyntax,
    for function: FunctionSyntax,
    in context: some MacroExpansionContext,
    using loggable: LoggableSyntax
  ) -> [CodeBlockItemSyntax] {
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
