import SwiftSyntax

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
