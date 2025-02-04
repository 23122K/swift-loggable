import SwiftSyntax

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
