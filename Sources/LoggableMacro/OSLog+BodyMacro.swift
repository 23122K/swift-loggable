import SwiftSyntax
import SwiftSyntaxMacros

public struct OSLog: LoggableMacro {
  static func loggable(
    of node: AttributeSyntax,
    in context: some MacroExpansionContext
  ) -> LoggableSyntax {
    LoggableSyntax(
      for: MemberAccessExprSyntax(
        name: .identifier("logger")
      ),
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
                base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
                declName: DeclReferenceExprSyntax(baseName: .identifier("logger"))
              )
            )
          )
        )
      )
    )
  }
}
