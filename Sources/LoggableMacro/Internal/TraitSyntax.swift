import SwiftSyntax

public struct TraitSyntax: Sendable {
  let syntax: ExprSyntax
  let traits: [Trait] = []

  public enum Trait: Sendable {
    case parameters
    case result
  }

  public init(syntax: ExprSyntax) {
    self.syntax = syntax
  }
}
