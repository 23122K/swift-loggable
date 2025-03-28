import SwiftSyntax

extension TokenSyntax {
  enum Predefined {
    case `_`
    case log
    case Log
    case emit
    case event
    case Event
    case error
    case result
    case location
    case `default`
    case loggable
    case Loggable
    case parameters
    case signposter
    case declaration
    case Conformance

    var identifier: TokenSyntax {
      switch self {
      case ._:
        return TokenSyntax.identifier("_")
        
      case .log:
        return TokenSyntax.identifier("log")

      case .Log:
        return TokenSyntax.identifier("Log")

      case .emit:
        return TokenSyntax.identifier("emit")

      case .event:
        return TokenSyntax.identifier("event")

      case .Event:
        return TokenSyntax.identifier("Event")

      case .error:
        return TokenSyntax.identifier("error")

      case .result:
        return TokenSyntax.identifier("result")

      case .location:
        return TokenSyntax.identifier("location")

      case .default:
        return TokenSyntax.identifier("default")

      case .loggable:
        return TokenSyntax.identifier("loggable")

      case .Loggable:
        return TokenSyntax.identifier("Loggable")

      case .parameters:
        return TokenSyntax.identifier("parameters")

      case .signposter:
        return TokenSyntax.identifier("signposter")

      case .declaration:
        return TokenSyntax.identifier("declaration")

      case .Conformance:
        return TokenSyntax.identifier("Conformance")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenSyntax {
    token.identifier
  }
}
