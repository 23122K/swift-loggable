import SwiftSyntax

extension SyntaxProtocol {
  func modify(_ build: @Sendable @escaping (inout Self) -> Self) -> Self {
    var copy = self
    return build(&copy)
  }
}
