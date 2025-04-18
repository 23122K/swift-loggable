import LoggableCore
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public class LogMacro: MacroBuilder.Body {
  typealias Argument = LoggableSyntax.ArgumentSyntax

  public static func expansion(
    of node: AttributeSyntax,
    for function: FunctionSyntax,
    in context: some MacroExpansionContext,
    using loggable: LoggableSyntax
  ) -> [CodeBlockItemSyntax] {
    return body {
      loggable.initialize()
      loggable.event(for: function, tags: function.traits.taggable)

      if !function.parameters.isEmpty || !function.traits.ommitable.contains(where: { $0 == .parameters}) {
        loggable.capture(
          .parameters(
            function.parameters.compactMap { parameter in
              if !function.traits.ommitable.contains(where: { $0 == .parameter(parameter.name.text) }) {
                return parameter
              }
              return nil
            }
          )
        )
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
        if !function.traits.ommitable.contains { $0 == .result } {
          loggable.capture(.result)
        }
        loggable.emit
        CodeBlockItemSyntax.return
      }
    }
  }
}
