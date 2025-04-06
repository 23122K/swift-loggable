import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct TagMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let declaration = DeclSyntax(declaration) else { return body() }
    switch declaration.as(DeclSyntaxEnum.self) {
    case let .functionDecl(syntax):
      let function = FunctionSyntax(syntax)
      guard function.attributes.contains(where: \.isLogMacroPresent) else {
        context.diagnose(
          Diagnostic(
            node: node,
            message: .tagMacroMustPreceedLogMacro
          )
        )
        return body()
      }
      return body()

    default:
      return body()
    }
  }
}
