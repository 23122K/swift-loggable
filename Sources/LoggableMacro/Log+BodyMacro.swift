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
          let declaration = declaration.as(FunctionDeclSyntax.self)
    else { return body() }
    
    
    return body {
      let loggable = LoggableSyntax(for: node.loggable)
      
      CodeBlockItemSyntax.copy(declaration)
      loggable.log {
        Argument(.location, content: location)
        Argument(.of, content: declaration.calee)
      }
      
// TODO: - Hande the logging of parametres provided to a function
//      if declaration.hasParameters {
//        loggable.log {
//          Argument(.parameters, content: "Parameters")
//        }
//      }
      
      
      if declaration.isThrowing {
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(declaration)
          if !declaration.signature.isVoid { // TODO: - Handle case when function retuns Void
            loggable.log {
              Argument(.result, reference: .result)
            }
            CodeBlockItemSyntax.return
          }
        } catch: {
          loggable.log {
            Argument(.error, reference: .error)
          }
          CodeBlockItemSyntax.rethrow
        }
      } else {
        CodeBlockItemSyntax.call(declaration)
        if !declaration.signature.isVoid { // TODO: - Handle case when function retuns Void
          loggable.log {
            Argument(.result, reference: .result)
          }
          CodeBlockItemSyntax.return
        }
      }
    }
  }
}
