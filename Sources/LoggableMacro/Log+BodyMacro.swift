import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LogMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]
  typealias Argument = LoggableSyntax.ArgumentSyntax
  
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let location = context.location(of: declaration)?.findable,
          let function = FunctionSyntax(from: declaration)
    else { return body() }
    
    return body {
      // TODO: - Hande the logging of parametres provided to a function
      let loggable = LoggableSyntax(for: node.loggable)
      switch function.isThrowing {
      case false where function.isVoid:
        loggable.log {
          Argument(.at, content: location)
          Argument(.of, content: function.description)
        }
        
      case true where function.isVoid:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
        } catch: {
          loggable.log {
            Argument(.at, content: location)
            Argument(.of, content: function.description)
            Argument(.error, reference: .error)
          }
          CodeBlockItemSyntax.rethrow
        }
        
      case true:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
          loggable.log {
            Argument(.at, content: location)
            Argument(.of, content: function.description)
            Argument(.result, reference: .result)
          }
          CodeBlockItemSyntax.return
        } catch: {
          loggable.log {
            Argument(.at, content: location)
            Argument(.of, content: function.description)
            Argument(.error, reference: .error)
          }
          CodeBlockItemSyntax.rethrow
        }
        
      case false:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
        loggable.log {
          Argument(.at, content: location)
          Argument(.of, content: function.description)
          Argument(.result, reference: .result)
        }
        CodeBlockItemSyntax.return
      }
    }
  }
}
