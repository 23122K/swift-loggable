import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

protocol LoggableAttributeMacro: MemberAttributeMacro {
  static func introduce(for node: AttributeSyntax) -> AttributeSyntax
  static func ignore(_ attribute: AttributeSyntax) -> Bool
}

extension LoggableAttributeMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AttributeSyntax] {
    guard let member = FunctionDeclSyntax(member) else {
      return self.attriibutes()
    }

    let canExpand = member.attributes.map { attribute in
      guard case let .attribute(syntax) = attribute else { return false }
      return self.ignore(syntax)
    }

    return canExpand.contains(true)
      ? self.attriibutes()
      : self.attriibutes {
        self.introduce(for: node)
      }
  }
}

struct DebugException: DiagnosticMessage {
  var message: String
  
  var diagnosticID: SwiftDiagnostics.MessageID { .init(domain: "d", id: "1") }

  var severity: SwiftDiagnostics.DiagnosticSeverity { .error }
}
