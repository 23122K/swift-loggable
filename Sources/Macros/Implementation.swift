import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension AbstractSourceLocation {
  var findable: String {
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

extension Sequence {
  var elements: [Element] { Array(self) }
}

extension FunctionParameterSyntax {
  var argument: TokenSyntax {
    guard let identifer = self.secondName else {
      return self.firstName
    }
    
    return identifer
  }
  
  var isInout: Bool {
    guard let attributedType = AttributedTypeSyntax(self.type) else {
      return false
    }
    
    return attributedType.specifiers.contains { specifierType in
      switch specifierType {
      case let .simpleTypeSpecifier(syntax) where syntax.specifier.tokenKind == .keyword(.inout):
        return true
        
      default:
        return false
      }
    }
  }
  
  func asLabeledExprSyntax(trailingComma presence: SourcePresence) -> LabeledExprSyntax {
    guard isInout else {
      return LabeledExprSyntax(
        label: self.argument,
        colon: .colonToken(),
        expression: DeclReferenceExprSyntax(baseName: self.argument),
        trailingComma: .commaToken(presence: presence)
      )
    }
    
    return LabeledExprSyntax(
      label: self.argument,
      colon: .colonToken(),
      expression: InOutExprSyntax(
        expression: DeclReferenceExprSyntax(baseName: self.argument)
      ),
      trailingComma: .commaToken(presence: presence)
    )
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
  
  var asLabeledExprSyntax: LabeledExprListSyntax {
    LabeledExprListSyntax(
      self.parameters.map { parameter in
        let presence: SourcePresence = parameters.last == parameter
          ? .missing
          : .present
        
        return parameter.asLabeledExprSyntax(trailingComma: presence)
      }
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
  var simplified: FunctionDeclSyntax {
    var declaration = self
    declaration.attributes = []
    declaration.name = .identifier("_\(declaration.name.text)")
    declaration.signature = declaration.signature.simplifySignature
    return declaration
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
}

extension TokenSyntax {
  static let resultIdentifer = TokenSyntax(
    .identifier("result"),
    presence: .present
  )
  
  static let errorIdentifer = TokenSyntax(
    .identifier("error"),
    presence: .present
  )
}

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
  
  static func log(for declName: DeclReferenceExprSyntax, location: String) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(
              baseName: .identifier("Loggable")
            ),
            period: .periodToken(),
            declName: declName
          ),
          period: .periodToken(),
          name: .identifier("message")
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax(
          arrayLiteral: LabeledExprSyntax(
            label: .identifier("location"),
            colon: .colonToken(),
            expression: StringLiteralExprSyntax(
              content: location
            )
          )
        ),
        rightParen: .rightParenToken()
      )
    )
  }
  
  static func throwError() -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      ThrowStmtSyntax(
        expression: DeclReferenceExprSyntax(
          baseName: .errorIdentifer
        )
      )
    )
  }
  
  static func copy(declaration syntax: FunctionDeclSyntax) -> CodeBlockItemSyntax {
    self.init(syntax)
  }
  
  static func `try`(
    do doStatements: CodeBlockItemListSyntax,
    catch catchStatements: CodeBlockItemListSyntax
  ) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      DoStmtSyntax(
        body: CodeBlockSyntax(
          statements: doStatements
        ),
        catchClauses: CatchClauseListSyntax(
          arrayLiteral: CatchClauseSyntax(
            body: CodeBlockSyntax(
              statements: catchStatements
            )
          )
        )
      )
    )
  }
}

extension TryExprSyntax {
  init(_ expression: FunctionCallExprSyntax) {
    self.init(expression: expression)
  }
  
  init(_ expression: AwaitExprSyntax) {
    self.init(expression: expression)
  }
}

extension AwaitExprSyntax {
  init(_ expression: FunctionCallExprSyntax) {
    self.init(expression: expression)
  }
}

extension FunctionDeclSyntax {
  var isAsync: Bool {
    self.signature.effectSpecifiers?.asyncSpecifier != nil
  }
  
  var isThrowing: Bool {
    self.signature.effectSpecifiers?.throwsClause != nil
  }
  
  func asInitializerClauseSyntax() -> InitializerClauseSyntax {
    let expression = FunctionCallExprSyntax(
      calledExpression: DeclReferenceExprSyntax(
        baseName: .identifier("_\(self.name.text)")
      ),
      leftParen: .leftParenToken(),
      arguments: self.signature.parameterClause.asLabeledExprSyntax,
      rightParen: .rightParenToken()
    )
    
    switch (self.isThrowing, self.isAsync) {
    case (true, true):
      let awaitExprSyntax = AwaitExprSyntax(expression)
      let tryExprSyntax = TryExprSyntax(awaitExprSyntax)
      return .init(value: tryExprSyntax)
      
    case (true, false):
      let tryExprSyntax = TryExprSyntax(expression)
      return .init(value: tryExprSyntax)
      
    case (false, true):
      let awaitExprSyntax = AwaitExprSyntax(expression)
      return .init(value: awaitExprSyntax)
      
    case (false, false):
      return .init(value: expression)
    }
  }
}

/// Wraps body of given function and assigns it to a result variable
extension CodeBlockItemSyntax {
  static func call(_ functionDeclSyntax: FunctionDeclSyntax) -> CodeBlockItemSyntax {
    CodeBlockItemSyntax(
      item: .decl(
        DeclSyntax(
          VariableDeclSyntax(
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax(
              arrayLiteral: PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                  identifier: .resultIdentifer
                ),
                initializer: functionDeclSyntax.asInitializerClauseSyntax()
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
            baseName: .resultIdentifer
          )
        )
      )
    )
  )
}
