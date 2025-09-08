import SwiftSyntax

extension TokenKind {
  static func variable(_ token: LoggableMacroTokens.Variable) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
  
  static func parameter(_ token: LoggableMacroTokens.Parameter) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
  
  static func function(_ token: LoggableMacroTokens.Function) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
  
  static func keyword(_ token: LoggableMacroTokens.Keyword) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
  
  static func conformance(_ token: LoggableMacroTokens.Conformance) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
  
  static func type(_ token: LoggableMacroTokens.`Type`) -> TokenKind {
    TokenKind.identifier(token.rawValue)
  }
}
