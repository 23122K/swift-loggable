import SwiftSyntax

extension TokenKind {
  enum Predefined {
    case autoclosure
    case capture
    case using
    case omit
    case Redact
    case Omit
    case Log
    case Logged
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

      case .omit:
        return TokenKind.identifier("omit")

      case .Log:
        return TokenKind.identifier("Log")

      case .Redact:
        return TokenKind.identifier("Redact")

      case .Logged:
        return TokenKind.identifier("Logged")

      case .redactableTraits:
        return TokenKind.identifier("redactableTraits")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenKind {
    token.identifer
  }
}
