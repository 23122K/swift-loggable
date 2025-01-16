import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LogMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]
  
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let location = context.location(of: declaration)?.findable,
          let declaration = declaration.as(FunctionDeclSyntax.self)
    else { return body() }
    
    return body {
      CodeBlockItemSyntax.copy(declaration)
      CodeBlockItemSyntax.log(for: node.logger, location: location)
      
      if declaration.isThrowing {
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(declaration)
          CodeBlockItemSyntax.return
        } catch: {
          CodeBlockItemSyntax.rethrow
        }
      } else {
        CodeBlockItemSyntax.call(declaration)
        CodeBlockItemSyntax.return
      }
    }
  }
}
