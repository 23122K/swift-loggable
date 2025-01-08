import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension AbstractSourceLocation {
  var readable: String {
    let _file = self.file
      .trimmedDescription
      .replacingOccurrences(of: #"""#, with: "")
    
    let _line = self.line
      .trimmedDescription
    
    let _column = self.column
      .trimmedDescription
    
    return "\(_file):\(_line):\(_column)"
  }
}


public struct LogMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard let functionDeclSyntax = FunctionDeclSyntax(declaration) else {
      return []
    }
    
    let wrapped = functionDeclSyntax._wrapped

    return [
      CodeBlockItemSyntax.init(
        item: .decl(wrapped.asDeclSyntax)
      ),
      CodeBlockItemSyntax.wrap(),
      CodeBlockItemSyntax.return
    ]
  }
}

extension FunctionParameterSyntax {
  var argument: TokenSyntax {
    guard let identifer = self.secondName else {
      return self.firstName
    }
    
    return identifer
  }
  
  var simplify: FunctionParameterSyntax {
    self.modify { declaration in
      declaration.firstName = self.argument
      declaration.secondName = nil
      declaration.defaultValue = nil
      declaration.type = declaration.type.trimmed
      return declaration
    }
  }
}

extension FunctionParameterClauseSyntax {
  var simplifyParameters: FunctionParameterClauseSyntax {
    FunctionParameterClauseSyntax(
      parameters: FunctionParameterListSyntax(
        self.parameters.map(\.simplify)
      ),
      trailingTrivia: nil
    )
  }
}

extension FunctionSignatureSyntax {
  var simplifySignature: FunctionSignatureSyntax {
    return self.modify { signature in
      signature.parameterClause = signature.parameterClause.simplifyParameters
      return signature
    }
  }
}

extension FunctionDeclSyntax {
  var _wrapped: FunctionDeclSyntax {
    self.modify { declaration in
      declaration.attributes = [] // TODO: Create erase to remove all attributes and assign empty array
      declaration.name = .identifier("_\(declaration.name.text)")
      declaration.signature = declaration.signature.simplifySignature
      return declaration
    }
  }
  
  var filledParametres: FunctionParameterListSyntax {
    self.signature.parameterClause.parameters
  }
  
  var asDeclSyntax: DeclSyntax {
    DeclSyntax(self)
  }
}

extension FunctionCallExprSyntax {
  var readable: String {
    self.trimmedDescription
  }
  
  static func logger(_ identifer: String) -> Self {
    return Self(
      calledExpression: MemberAccessExprSyntax(
        base: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: .keyword(.Self)
          ),
          period: .periodToken(),
          declName: DeclReferenceExprSyntax(
            baseName: .identifier("logger")
          )
        ),
        period: .periodToken(),
        declName: DeclReferenceExprSyntax(
          baseName: .identifier("info")
        )
      ),
      leftParen: .leftParenToken(),
      arguments: LabeledExprListSyntax(
        arrayLiteral: LabeledExprListSyntax.Element(
          expression: DeclReferenceExprSyntax(
            baseName: .identifier(identifer)
          )
        )
      ),
      rightParen: .rightParenToken()
    )
  }
}

/// Wraps body of given function and assigns it to a result variable
extension CodeBlockItemSyntax {
  static func wrap() -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      item: .decl(
        DeclSyntax(
          VariableDeclSyntax(
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax(
              arrayLiteral: PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                  identifier: .identifier("result")
                ),
//                typeAnnotation: TypeAnnotationSyntax(
//                  colon: .colonToken(),
//                  type: IdentifierTypeSyntax(
//                    name: .identifier("Int")
//                  )
//                ),
                initializer: InitializerClauseSyntax(
                  value: FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(
                      baseName: .identifier("_bar")
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax(arrayLiteral:
                      LabeledExprSyntax(
                        label: "value",
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                          baseName: "value"
                        ),
                        trailingComma: .commaToken()
                      ),
                      LabeledExprSyntax(
                        label: "number",
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                          baseName: "number"
                        )
                      )
                    ),
                    rightParen: .rightParenToken()
                  )
                )
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
            baseName: .identifier("result")
          )
        )
      )
    )
  )
}

@main
struct LoggablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LogMacro.self
  ]
}
