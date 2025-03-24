import SwiftSyntax

extension TokenKind {
  enum Predefined {
    case autoclosure
    case using
    case Omit
    case Log

    var identifer: TokenKind {
      switch self {
      case .autoclosure:
        return TokenKind.identifier("autoclosure")

      case .using:
        return TokenKind.identifier("using")

      case .Omit:
        return TokenKind.identifier("Omit")

      case .Log:
        return TokenKind.identifier("Log")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenKind {
    token.identifer
  }
}
