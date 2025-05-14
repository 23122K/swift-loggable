import SwiftSyntax

extension DeclGroupSyntax {
  var isGeneric: Bool {
    return switch DeclSyntax(self).as(DeclSyntaxEnum.self) {
    case let .actorDecl(actorDeclSyntax):
      actorDeclSyntax.genericParameterClause != nil

    case let .classDecl(classDeclSyntax):
      classDeclSyntax.genericParameterClause != nil

    case let .structDecl(structDeclSyntax):
      structDeclSyntax.genericParameterClause != nil

    case let .enumDecl(enumDeclSyntax):
      enumDeclSyntax.genericParameterClause != nil

    case let .extensionDecl(extensionDeclSyntax):
      extensionDeclSyntax.genericWhereClause != nil

    default:
      false
    }
  }
}
