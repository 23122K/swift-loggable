import SwiftSyntax

extension SyntaxProtocol {
  mutating func mutate(_ build: @Sendable @escaping (inout Self) -> Self) -> Self {
    build(&self)
  }
  
  func modify(_ build: @Sendable @escaping (inout Self) -> Self) -> Self {
    var copy = self
    return build(&copy)
  }
}
