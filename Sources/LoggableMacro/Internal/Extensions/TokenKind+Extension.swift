import SwiftSyntax

extension TokenKind {
  struct Predefined {
    let autoclosure = TokenKind.identifier("autoclosure")
    let using = TokenKind.identifier("using")
    let omit = TokenKind.identifier("Omit")
    let log = TokenKind.identifier("Log")
  }

  static let predefined = Predefined()
}
