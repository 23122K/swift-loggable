import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

protocol TraitMacro: BodyMacro {
  static var message: any DiagnosticMessage { get }

  static func expansion(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> [CodeBlockItemSyntax]
}

extension TraitMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    switch DeclSyntax(declaration).as(DeclSyntaxEnum.self) {
    case .functionDecl:
      return self.expansion(of: node, in: context)

    default:
      return self.body()
    }
  }

  static func expansion(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> [CodeBlockItemSyntax] {
    context.diagnose(
      Diagnostic(
        node: node,
        message: self.message
      )
    )
    return self.body()
  }
}
