import SwiftSyntax

extension TokenKind {
  static let autoclosure = TokenKind.identifier("autoclosure")
  static let using = TokenKind.identifier("using")
  static let omit = TokenKind.identifier("Omit")
  static let log = TokenKind.identifier("Log")
}
