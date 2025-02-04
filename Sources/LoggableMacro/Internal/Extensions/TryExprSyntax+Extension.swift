import SwiftSyntax

extension TryExprSyntax {
  init(_ expression: FunctionCallExprSyntax) {
    self.init(expression: expression)
  }
  
  init(_ expression: AwaitExprSyntax) {
    self.init(expression: expression)
  }
}

