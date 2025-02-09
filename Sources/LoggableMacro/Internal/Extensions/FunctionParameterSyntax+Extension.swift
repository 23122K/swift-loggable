import SwiftSyntax
import OSLog

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
  
  var isAutoclosure: Bool {
    guard let attributedType = AttributedTypeSyntax(self.type) else {
      return false
    }
    
    return attributedType.attributes.contains { attribute in
      guard case let .attribute(syntax) = attribute else { return false }
      
      guard let name = syntax.attributeName.as(IdentifierTypeSyntax.self) else { return false }
      return name.name.tokenKind == .identifier("autoclosure")
    }
  }
  
  func asLabeledExprSyntax(trailingComma presence: SourcePresence) -> LabeledExprSyntax {
    if isInout {
      os_log("isInout")
      return LabeledExprSyntax(
        label: self.argument,
        colon: .colonToken(),
        expression: InOutExprSyntax(
          expression: DeclReferenceExprSyntax(baseName: self.argument)
        ),
        trailingComma: .commaToken(presence: presence)
      )
    } else if isAutoclosure {
      os_log("isAutoclosure")
      return LabeledExprSyntax(
        label: self.argument,
        colon: .colonToken(),
        expression: FunctionCallExprSyntax(
          calledExpression: DeclReferenceExprSyntax(baseName: self.argument),
          leftParen: .leftParenToken(),
          arguments: [],
          rightParen: .rightParenToken()
        ),
        trailingComma: .commaToken(presence: presence)
      )
    } else {
      os_log("Other")
      return LabeledExprSyntax(
        label: self.argument,
        colon: .colonToken(),
        expression: DeclReferenceExprSyntax(baseName: self.argument),
        trailingComma: .commaToken(presence: presence)
      )
    }
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
