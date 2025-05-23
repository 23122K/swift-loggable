import SwiftSyntax

extension CodeBlockItemSyntax {
  init(_ statement: some StmtSyntaxProtocol) {
    self.init(item: .stmt(StmtSyntax(statement)))
  }

  init(_ declaration: some DeclSyntaxProtocol) {
    self.init(item: .decl(DeclSyntax(declaration)))
  }

  init(_ expression: some ExprSyntaxProtocol) {
    self.init(item: .expr(ExprSyntax(expression)))
  }

  static let rethrow = CodeBlockItemSyntax(
    ThrowStmtSyntax(
      expression: DeclReferenceExprSyntax(
        baseName: .predefined(.error)
      )
    )
  )

  static func `try`(
  @ResultBuilder<CodeBlockItemSyntax> _ doStatements: @escaping () -> [CodeBlockItemSyntax],
  @ResultBuilder<CodeBlockItemSyntax> catch statements: @escaping () -> [CodeBlockItemSyntax]
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      DoStmtSyntax(
        body: CodeBlockSyntax(
          statements: CodeBlockItemListSyntax(doStatements())
        ),
        catchClauses: CatchClauseListSyntax(
          arrayLiteral: CatchClauseSyntax(
            body: CodeBlockSyntax(
              statements: CodeBlockItemListSyntax(statements())
            )
          )
        )
      )
    )
  }

  static func call(_ function: FunctionSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      item: .decl(
        DeclSyntax(
          VariableDeclSyntax(
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax(
              arrayLiteral: PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                  identifier: .predefined(
                    function.isVoid
                      ? ._
                      : .result
                  )
                ),
                initializer: function.initializer
              )
            )
          )
        )
      )
    )
  }

  static let `return` = CodeBlockItemSyntax(
    item: .stmt(
      StmtSyntax(
        ReturnStmtSyntax(
          expression: DeclReferenceExprSyntax(
            baseName: .predefined(.result)
          )
        )
      )
    )
  )
}
