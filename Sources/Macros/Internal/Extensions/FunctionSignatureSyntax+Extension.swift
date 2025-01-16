import SwiftSyntax

extension FunctionSignatureSyntax {
  var simplifySignature: FunctionSignatureSyntax {
    return self.modify { signature in
      signature.parameterClause = signature.parameterClause.simplifyParameters
      return signature
    }
  }
}
