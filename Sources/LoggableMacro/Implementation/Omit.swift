import SwiftDiagnostics
import SwiftParserDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct OmitMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    // TODO: Check if has parameters
    // parameter: nil/empty -> Can be attached to function as @Log @OSLog will be ommited
    // parameter: some -> Cant be attached if @Log @OSLog (@Logged...) is not present
    guard let function = FunctionSyntax(from: declaration) else { return self.body() }
    context.diagnose(
      Diagnostic(
        node: node,
        message: .omitMacroMustPreceedLogMacro
      )
    )
    return self.body()
  }
}

extension MacroExpansionContext {
  var isLoggedInContext: Bool {
    if let declSyntax = self.lexicalContext.first?.as(DeclSyntax.self) {
      switch declSyntax.as(DeclSyntaxEnum.self) {
      case let .actorDecl(syntax):
        return syntax.attributes.contains(where: \.isLogged)

      case let .classDecl(syntax):
        return syntax.attributes.contains(where: \.isLogged)

      case let .structDecl(syntax):
        return syntax.attributes.contains(where: \.isLogged)

      case let .extensionDecl(syntax):
        return syntax.attributes.contains(where: \.isLogged)

      case let .enumDecl(syntax):
        return syntax.attributes.contains(where: \.isLogged)

      default:
        return false
      }
    }
    return false
  }
}

extension DiagnosticMessage where Self == LoggableError {
  static var omitMacroCanOnlyBeUsedWithLogOrLoggableWithinContext: Self {
    return LoggableError(
      message: "blah",
      diagnosticID: .init(domain: "swiftpm.logging.error.omit-macro-must-preceed-log-macro", id: "22"),
      severity: .error
    )
  }

  static var omitMacroMustPreceedLogMacro: Self {
    return LoggableError(
      message: "@Omit macro must preceed @Log macro declaration",
      diagnosticID: .init(domain: "1", id: "swiftpm.logging.error.omit-macro-must-preceed-log-macro"),
      severity: .error
    )
  }

  static var tagMacroMustPreceedLogMacro: Self {
    return LoggableError(
      message: "@Tag macro must preceed @Log macro declaration",
      diagnosticID: .init(domain: "3", id: "swiftpm.logging.error.omit-macro-must-preceed-log-macro"),
      severity: .error
    )
  }

  static var redactMacroIsMissingArguments: Self {
    return LoggableError(
      message: "@Redact macro is missing arguments",
      diagnosticID: .init(domain: "redactMacroIsMissingArguments", id: "2"),
      severity: .error
    )
  }

  static func _debug(_ message: String) -> Self {
    LoggableError(
      message: message,
      diagnosticID: .init(domain: "domain", id: "id"),
      severity: .error
    )
  }
}

public struct LoggableError: DiagnosticMessage {
  public var message: String

  public var diagnosticID: MessageID
  public var severity: DiagnosticSeverity
}
