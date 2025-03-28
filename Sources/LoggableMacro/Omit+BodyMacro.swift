import SwiftDiagnostics
import SwiftParserDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct OmitMacro: BodyMacro, BodyMacroBuilder {
  typealias Body = [CodeBlockItemSyntax]

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    guard
      let function = FunctionSyntax(from: declaration),
      case .argumentList = node.arguments
    else { return body() }

    let diagnostic = Diagnostic(
      node: node,
      message: .omitMacroMustPreceedLogMacro
    )

    context.diagnose(diagnostic)
    return body()
  }
}

extension DiagnosticMessage where Self == LoggableError {
  static var omitMacroMustPreceedLogMacro: Self {
    return LoggableError(
      message: "@Omit macro must preceed @Log macro declaration",
      diagnosticID: .init(domain: "1", id: "swiftpm.logging.error.omit-macro-must-preceed-log-macro"),
      severity: .error
    )
  }

  static var redactMacroMustPreceedLogMacro: Self {
    return LoggableError(
      message: "@Redact macro must preceed @Log macro declaration",
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
