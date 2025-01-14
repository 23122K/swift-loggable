import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct OmitMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] { return [] }
}
