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
    
    let loggable = LoggableSyntax(for: node.loggable)
    
    return body {
      CodeBlockItemSyntax(function.declaration.plain)
      loggable.log {
        Argument(.location, content: location)
        Argument(.of, content: function.declaration.description)
      }
      
// TODO: - Hande the logging of parametres provided to a function
//      if declaration.hasParameters {
//        loggable.log {
//          Argument(.parameters, content: "Parameters")
//        }
//      }
      
      switch function.declaration.signature.isThrowing {
      case true where function.declaration.signature.isVoid,
        false where function.declaration.signature.isVoid: []
        
      case true:
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
          loggable.log {
            Argument(.result, reference: .result)
          }
          CodeBlockItemSyntax.return
        } catch: {
          loggable.log {
            Argument(.error, reference: .error)
          }
          CodeBlockItemSyntax.rethrow
        }
        
      case false:
        CodeBlockItemSyntax.call(function)
        loggable.log {
          Argument(.result, reference: .result)
        }
        CodeBlockItemSyntax.return
      }
    }
  }
}
