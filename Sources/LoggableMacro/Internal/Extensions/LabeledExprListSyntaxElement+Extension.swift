import SwiftSyntax

extension LabeledExprListSyntax.Element {
  func parameter(is tokenKind: TokenKind) -> Bool {
    self.label?.tokenKind == tokenKind
  }
}
