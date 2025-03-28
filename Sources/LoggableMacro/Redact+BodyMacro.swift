import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RedactMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]

  static public func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard case .argumentList = node.arguments else {
      context.diagnose(
        Diagnostic(
          node: node,
          message: .redactMacroIsMissingArguments
        )
      )
      return body()
    }

    // TODO: - Check if declaration contains Log macro LabeledExprSyntax
    // if contains
    //    diagnose that it must preceed @Log macro declaration
    // else
    //    diagnose that it must implement @Log macro

    context.diagnose(
      Diagnostic(
        node: node,
        message: .redactMacroMustPreceedLogMacro
      )
    )
    return body()
  }
}
