import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

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
      return self.attributes()
    }

    let canExpand = member.attributes.map { attribute in
      guard case let .attribute(syntax) = attribute else { return false }
      return self.ignore(syntax)
    }
//    
//    context.diagnose(
//      .init(
//        node: node,
//        message: .debug(self.introduce(for: node))
//      )
//    )

    return canExpand.contains(true)
      ? self.attributes()
      : self.attributes {
        self.introduce(for: node)
      }
  }
}

struct DebugException: DiagnosticMessage {
  var message: String

  var diagnosticID: SwiftDiagnostics.MessageID { .init(domain: "d", id: "1") }

  var severity: SwiftDiagnostics.DiagnosticSeverity { .error }
}
