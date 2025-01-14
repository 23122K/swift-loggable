import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LogMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let location = context.location(of: declaration)?.findable,
          let declaration = declaration.as(FunctionDeclSyntax.self)
    else { return [] }
    
    return CodeBlockItemListSyntax {
      CodeBlockItemSyntax.log(for: node.logger ,location: location)
      CodeBlockItemSyntax.copy(declaration: declaration.simplified)
      
      if declaration.isThrowing {
        CodeBlockItemSyntax.try(
          do: [
            CodeBlockItemSyntax.call(declaration),
            CodeBlockItemSyntax.return
          ],
          catch: [
            CodeBlockItemSyntax.throwError()
          ]
        )
      } else {
        CodeBlockItemSyntax.call(declaration)
        CodeBlockItemSyntax.return
      }
    }
    .elements
  }
}

extension AttributeSyntax {
  var logger: DeclReferenceExprSyntax {
    switch self.arguments {
    case let .argumentList(arguments):
      guard let expression = MemberAccessExprSyntax(arguments.first?.expression)
      else { fallthrough }
      return expression.declName
      
    default:
      return DeclReferenceExprSyntax(
        baseName: .identifier("default")
      )
    }
  }
}

