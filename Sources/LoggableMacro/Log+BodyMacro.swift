import SwiftSyntax
import SwiftDiagnostics
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

    context.diagnose(
      Diagnostic(
        node: node,
        message: ._debug(function.traits.debugDescription)
      )
    )

    return body {
      let loggable = LoggableSyntax(for: node.loggable)
      loggable.initialize()
      loggable.event(at: location, for: function)

      if !function.parameters.isEmpty {
        loggable.capture(.parameters(function.parameters))
      }

      switch function.isThrowing {
      case false where function.isVoid:
        function.body
        loggable.emit

      case true where function.isVoid:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
        } catch: {
          loggable.capture(.error)
          loggable.emit
          CodeBlockItemSyntax.rethrow
        }

      case true:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.try {
          CodeBlockItemSyntax.call(function)
          loggable.capture(.result)
          loggable.emit
          CodeBlockItemSyntax.return
        } catch: {
          loggable.capture(.error)
          loggable.emit
          CodeBlockItemSyntax.rethrow
        }

      case false:
        CodeBlockItemSyntax(function.plain)
        CodeBlockItemSyntax.call(function)
//        loggable.capture(.result)
        loggable.emit
        CodeBlockItemSyntax.return
      }
    }
  }
}
