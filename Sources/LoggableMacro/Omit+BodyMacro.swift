import SwiftSyntax
import SwiftSyntaxMacros

public struct OmitMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] { body() }
}
