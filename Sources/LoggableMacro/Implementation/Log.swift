import LoggableCore
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LogMacro: LoggableMacro {
  static func loggable(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> LoggableSyntax {
    LoggableSyntax(
      for: node.loggable,
      in: context.location(of: node)?.findable ?? ""
    )
  }

  static func initalize(_ loggable: LoggableSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.let),
        bindings: PatternBindingListSyntax(
          arrayLiteral: PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: .predefined(.loggable)
            ),
            typeAnnotation: TypeAnnotationSyntax(
              type: SomeOrAnyTypeSyntax(
                someOrAnySpecifier: .keyword(.any),
                constraint:IdentifierTypeSyntax(
                  name: .predefined(.Loggable)
                )
              )
            ),
            initializer: InitializerClauseSyntax(
              value: MemberAccessExprSyntax(
                declName: DeclReferenceExprSyntax(loggable.expression)!
              )
            )
          )
        )
      )
    )
  }
}
