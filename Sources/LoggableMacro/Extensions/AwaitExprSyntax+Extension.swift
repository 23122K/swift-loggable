import SwiftSyntax

extension AwaitExprSyntax {
  init(_ expression: FunctionCallExprSyntax) {
    self.init(expression: expression)
  }
}
