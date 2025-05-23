import SwiftSyntax

extension TokenKind {
  enum Predefined {
    case autoclosure
    case capture
    case using
    case access
    case omit
    case tag
    case Tag
    case Omit
    case Log
    case level
    case Level
    case OSLog
    case Logged
    case subsystem
    case category

    var identifier: TokenKind {
      switch self {
      case .access:
        return TokenKind.identifier("access")

      case .level:
        return TokenKind.identifier("level")

      case .Level:
        return TokenKind.identifier("Level")

      case .subsystem:
        return TokenKind.identifier("subsystem")

      case .OSLog:
        return TokenKind.identifier("OSLog")

      case .category:
        return TokenKind.identifier("category")

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

      case .Tag:
        return TokenKind.identifier("Tag")

      case .tag:
        return TokenKind.identifier("tag")

      case .Logged:
        return TokenKind.identifier("Logged")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenKind {
    token.identifier
  }
}
