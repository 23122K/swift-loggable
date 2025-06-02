import SwiftSyntax

typealias EmptyStringLiteralExprSyntax = StringLiteralExprSyntax

extension EmptyStringLiteralExprSyntax {
  init() {
    self.init(content: "")
  }
}
