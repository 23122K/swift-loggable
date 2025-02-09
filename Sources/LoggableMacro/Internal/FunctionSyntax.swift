import SwiftSyntax

struct FunctionSyntax {
  let declaration: Declaration
  
  struct Declaration {
    let syntax: FunctionDeclSyntax
    let signature: Signature
    
    /// Returns function call description
    var description: String {
      var syntax = self.syntax
      syntax.attributes = []
      syntax.body = nil
      return syntax.trimmedDescription
    }
    
    var initializer: InitializerClauseSyntax {
      let expression = FunctionCallExprSyntax(
        calledExpression: DeclReferenceExprSyntax(
          baseName: .identifier("_\(self.syntax.name.text)")
        ),
        leftParen: .leftParenToken(),
        arguments: self.signature.asLabeledExprSyntax,
        rightParen: .rightParenToken()
      )
      
      switch (self.signature.isThrowing, self.signature.isAsync) {
      case (true, true):
        let awaitExprSyntax = AwaitExprSyntax(expression)
        let tryExprSyntax = TryExprSyntax(awaitExprSyntax)
        return InitializerClauseSyntax(value: tryExprSyntax)
        
      case (true, false):
        let tryExprSyntax = TryExprSyntax(expression)
        return InitializerClauseSyntax(value: tryExprSyntax)
        
      case (false, true):
        let awaitExprSyntax = AwaitExprSyntax(expression)
        return InitializerClauseSyntax(value: awaitExprSyntax)
        
      case (false, false):
        return InitializerClauseSyntax(value: expression)
      }
    }
    
    /// Returns `true` if function has any generic parameters, otherwise returns `false`
    var isGeneric: Bool { self.syntax.genericParameterClause != nil }
    
    /// Returns `FunctionDeclSyntax` prefixed with `_` without any attributes, modifiers, generic declarations and with
    /// its signature simplified
    var plain: FunctionDeclSyntax {
      var syntax = self.syntax
      syntax.attributes = []
      syntax.modifiers = []
      syntax.name = .identifier("_\(self.syntax.name.text)")
      syntax.signature = self.signature.plain
      syntax.genericParameterClause = nil
      syntax.genericWhereClause = nil
      return syntax
    }
    
    struct Signature {
      let syntax: FunctionSignatureSyntax
      let parameters: [Parameter]
      
      /// Returns `true` when function signature has no retrun clause attatch to it, otherwise returns `false`
      var isVoid: Bool { self.syntax.returnClause == nil }
      
      /// Returns `true` when function has async, otherwise returns `false`
      var isAsync: Bool { self.syntax.effectSpecifiers?.asyncSpecifier != nil }
      
      /// Returns `true` if function signature specifyies that it can throw errors, otherwise `false` is retruned
      var isThrowing: Bool { self.syntax.effectSpecifiers?.throwsClause != nil }
      
      var asLabeledExprSyntax: LabeledExprListSyntax {
        LabeledExprListSyntax(
          self.parameters.map { parameter in
            let presence: SourcePresence = self.parameters.last == parameter
              ? .missing
              : .present
            return parameter.asLabeledExprSyntax(trailingComma: presence)
          }
        )
      }
      
      /// Returns `FunctionSignatureSyntax` which parameters has been stripped of parametr label, default value and its types
      var plain: FunctionSignatureSyntax {
        var syntax = self.syntax
        syntax.parameterClause.parameters = FunctionParameterListSyntax(self.parameters.map(\.plain))
        return syntax
      }
      
      struct Parameter: Equatable {
        let syntax: FunctionParameterSyntax
        
        var isInout: Bool {
          guard let attributedType = AttributedTypeSyntax(self.syntax.type)
          else { return false }
          
          return attributedType.specifiers.contains { specifierType in
            switch specifierType {
            case let .simpleTypeSpecifier(syntax) where syntax.specifier.tokenKind == .keyword(.inout):
              return true
              
            default:
              return false
            }
          }
        }
        
        var isAutoclosure: Bool {
          guard let attributedType = AttributedTypeSyntax(self.syntax.type)
          else { return false }
          
          return attributedType.attributes.contains { attribute in
            guard case let .attribute(syntax) = attribute else { return false }
            guard let name = syntax.attributeName.as(IdentifierTypeSyntax.self) else { return false }
            return name.name.tokenKind == .autoclosure
          }
        }
        
        func asLabeledExprSyntax(trailingComma presence: SourcePresence) -> LabeledExprSyntax {
          switch (self.isInout, self.isAutoclosure) {
          case (true, false):
            return LabeledExprSyntax(
              label: self.name,
              colon: .colonToken(),
              expression: InOutExprSyntax(
                expression: DeclReferenceExprSyntax(baseName: self.name)
              ),
              trailingComma: .commaToken(presence: presence)
            )
            
          case (false, true):
            return LabeledExprSyntax(
              label: self.name,
              colon: .colonToken(),
              expression: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: self.name),
                leftParen: .leftParenToken(),
                arguments: [],
                rightParen: .rightParenToken()
              ),
              trailingComma: .commaToken(presence: presence)
            )
            
          default:
            return LabeledExprSyntax(
              label: self.name,
              colon: .colonToken(),
              expression: DeclReferenceExprSyntax(baseName: self.name),
              trailingComma: .commaToken(presence: presence)
            )
          }
        }
        
        /// Returns function parameter name if a function specified parameter label otherwise returns parameter name
        /// Used mainly for simplifying delcaration of a copied declaration function so parameters can be passed to its copy
        var name: TokenSyntax {
          guard let identifer = self.syntax.secondName
          else { return self.syntax.firstName }
          return identifer
        }
        
        /// Retruns `FunctionParameterSyntax` that is stripped of parameter label, default value and its type
        var plain: FunctionParameterSyntax {
          var syntax = self.syntax
          syntax.firstName = self.name
          syntax.secondName = nil
          syntax.defaultValue = nil
          syntax.type = self.syntax.type.trimmed
          return syntax
        }
      }
      
      init(syntax: FunctionSignatureSyntax) {
        self.syntax = syntax
        self.parameters = syntax.parameterClause.parameters.map(Parameter.init)
        }
      }
    
    init(_ syntax: FunctionDeclSyntax) {
      self.syntax = syntax
      self.signature = Signature(syntax: syntax.signature)
    }
  }
  
  init(_ syntax: FunctionDeclSyntax) {
    self.declaration = Declaration(syntax)
  }
  
  init?(from syntax: some DeclSyntaxProtocol) {
    guard let syntax = syntax.as(FunctionDeclSyntax.self)
    else { return nil }
    self.init(syntax)
  }
}
