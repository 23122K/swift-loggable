import SwiftSyntax

extension AttributeSyntax {
  var loggable: ExprSyntax {
    switch self.arguments {
    case let .argumentList(arguments):
      for argument in arguments {
        switch argument {
        case let argument where argument.label?.tokenKind == .using:
          switch argument.expression {
          case let expression where expression.is(DeclReferenceExprSyntax.self):
            return expression
            
          case let expression where expression.is(MemberAccessExprSyntax.self):
            let syntax = expression.as(MemberAccessExprSyntax.self).unsafelyUnwrapped
            return syntax.base == nil
              ? Self.fallback(for: syntax.declName)
              : expression
            
          case let expression where expression.is(FunctionCallExprSyntax.self):
            return expression
          
          default:
            continue
          }

        default:
          continue
        }
      }
      fallthrough
      
    default:
      return Self.fallback()
    }
  }
  
  static func copy(_ syntax: AttributeSyntax) -> AttributeSyntax {
    var syntax = syntax
    syntax.attributeName = TypeSyntax(
      IdentifierTypeSyntax(name: .Log)
    )
    return syntax
  }
  
  private static func fallback(
    for declName: DeclReferenceExprSyntax = DeclReferenceExprSyntax(baseName: .default)
  ) -> ExprSyntax {
    ExprSyntax(
      MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(
          baseName: .Loggable
        ),
        period: .periodToken(),
        declName: declName
      )
    )
  }
}
