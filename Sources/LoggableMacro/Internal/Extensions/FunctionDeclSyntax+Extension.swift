import SwiftSyntax

extension FunctionDeclSyntax {
  var simplified: FunctionDeclSyntax {
    var declaration = self
    declaration.attributes = []
    declaration.modifiers = []
    declaration.name = .identifier("_\(declaration.name.text)")
    declaration.signature = declaration.signature.simplifySignature
    declaration.genericParameterClause = nil
    declaration.genericWhereClause = nil
    return declaration
  }
  
  var filledParametres: FunctionParameterListSyntax {
    self.signature.parameterClause.parameters
  }
  
  var calee: String {
    var declaration = self
    declaration.attributes = []
    declaration.body = nil
    return declaration.trimmedDescription
  }
  
  var isGeneric: Bool {
    self.genericParameterClause != nil
  }
  
  var isAsync: Bool {
    self.signature.effectSpecifiers?.asyncSpecifier != nil
  }
  
  var isThrowing: Bool {
    self.signature.effectSpecifiers?.throwsClause != nil
  }
  
  var hasParameters: Bool {
    self.signature.parameterClause.parameters.isEmpty == false
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
