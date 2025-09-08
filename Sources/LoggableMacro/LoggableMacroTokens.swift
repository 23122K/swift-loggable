import SwiftSyntax

enum LoggableMacroTokens {
  enum Variable: String {
    case event
    case error
    case result
    case failure
    case success
    case loggable
    case logger
    case main
    case bundleIdentifier
  }
  
  enum Parameter: String {
    case tag
    case omit
    case tags
    case level
    case location
    case declaration
    case using
    case access
    case parameters
    case subsystem
    case category
    case reflecting
  }
  
  enum Function: String {
    case emit
  }
  
  enum Conformance: String {
    case Loggable
  }
  
  enum `Type`: String {
    case Tag
    case Log
    case Omit
    case Level
    case OSLog
    case Logger
    case Bundle
    case String
    case LoggableEvent
  }
  
  enum Keyword: String {
    case underscore = "_"
    case doubleQuestionMark = "??"
  }
}
