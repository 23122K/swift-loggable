import SwiftSyntax

extension TokenSyntax {
  enum Predefined {
    case `_`
    case doubleQuestionMark
    case log
    case tags
    case Log
    case OSLog
    case emit
    case event
    case Event
    case error
    case result
    case location
    case `default`
    case failure
    case success
    case loggable
    case logger
    case Logger
    case Loggable
    case parameters
    case declaration
    case Conformance
    case LoggableEvent
    case Omit
    case Redact
    case subsystem
    case category
    case bundleIdentifier
    case Bundle
    case main

    var identifier: TokenSyntax {
      switch self {
      case ._:
        return TokenSyntax.identifier("_")

      case .doubleQuestionMark:
        return TokenSyntax.identifier("??")

      case .bundleIdentifier:
        return TokenSyntax.identifier("bundleIdentifier")

      case .Bundle:
        return TokenSyntax.identifier("Bundle")

      case .main:
        return TokenSyntax.identifier("main")

      case .logger:
        return TokenSyntax.identifier("logger")

      case .Logger:
        return TokenSyntax.identifier("Logger")

      case .subsystem:
        return TokenSyntax.identifier("subsystem")

      case .category:
        return TokenSyntax.identifier("category")

      case .failure:
        return TokenSyntax.identifier("failure")

      case .success:
        return TokenSyntax.identifier("success")

      case .tags:
        return TokenSyntax.identifier("tags")

      case .log:
        return TokenSyntax.identifier("log")

      case .Log:
        return TokenSyntax.identifier("Log")

      case .OSLog:
        return TokenSyntax.identifier("OSLog")

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

      case .declaration:
        return TokenSyntax.identifier("declaration")

      case .Conformance:
        return TokenSyntax.identifier("Conformance")

      case .LoggableEvent:
        return TokenSyntax.identifier("LoggableEvent")

      case .Omit:
        return TokenSyntax.identifier("Omit")

      case .Redact:
        return TokenSyntax.identifier("Redact")
      }
    }
  }

  static func predefined(_ token: Predefined) -> TokenSyntax {
    token.identifier
  }
}
