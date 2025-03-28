import SwiftSyntax

extension TokenKind {
  enum Predefined {
    case autoclosure
    case capture
    case using
    case Omit
    case Log
    case redactableTraits

    var identifer: TokenKind {
      switch self {
      case .capture:
        return TokenKind.identifier("capture")

      case .autoclosure:
        return TokenKind.identifier("autoclosure")

      case .using:
        return TokenKind.identifier("using")

      case .Omit:
        return TokenKind.identifier("Omit")

      case .Log:
        return TokenKind.identifier("Log")

      case .redactableTraits:
        return TokenKind.identifier("redactableTraits")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenKind {
    token.identifer
  }
}
