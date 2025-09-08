import SwiftSyntax

extension TokenSyntax {
  static func variable(_ token: LoggableMacroTokens.Variable) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }
  
  static func parameter(_ token: LoggableMacroTokens.Parameter) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }
  
  static func function(_ token: LoggableMacroTokens.Function) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }
  
  static func keyword(_ token: LoggableMacroTokens.Keyword) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }
  
  static func conformance(_ token: LoggableMacroTokens.Conformance) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }
  
  static func type(_ token: LoggableMacroTokens.`Type`) -> TokenSyntax {
    TokenSyntax.identifier(token.rawValue)
  }

  var isAccessModifier: Bool {
    Self.accessLevels.contains(self.tokenKind)
  }

  private static let accessLevels = [
    TokenKind.keyword(.open),
    TokenKind.keyword(.final),
    TokenKind.keyword(.public),
    TokenKind.keyword(.package),
    TokenKind.keyword(.internal),
    TokenKind.keyword(.fileprivate),
    TokenKind.keyword(.private),
  ]
}
