import SwiftSyntax

extension TokenSyntax {
  struct Predefined {
    let log = TokenSyntax.identifier("log")
    let Log = TokenSyntax.identifier("Log")
    let emit = TokenSyntax.identifier("emit")
    let event = TokenSyntax.identifier("event")
    let Event = TokenSyntax.identifier("Event")
    let error = TokenSyntax.identifier("error")
    let result = TokenSyntax.identifier("result")
    let location = TokenSyntax.identifier("location")
    let `default` = TokenSyntax.identifier("default")
    let Loggable = TokenSyntax.identifier("Loggable")
    let parameters = TokenSyntax.identifier("parameters")
    let declaration = TokenSyntax.identifier("declaration")
  }

  static let predefined = Predefined()
}
