import Foundation
import LoggableCore
import SwiftSyntax

// TODO: Move to LoggableSyntax
enum LoggbleAttributeSyntax {
  case Log([OmmitableTrait] = [])
  case Omit([OmmitableTrait] = [])
}

extension AttributeListSyntax {
  var _attributes: [LoggbleAttributeSyntax] {
    self.compactMap { element in
      switch element {
      case let .attribute(attributeSyntax):
        let tokenKind = IdentifierTypeSyntax(attributeSyntax.attributeName)?.name.tokenKind
        let arguments = LabeledExprListSyntax(attributeSyntax.arguments)?
          .compactMap { argument -> OmmitableTrait? in
            switch argument.expression.as(ExprSyntaxEnum.self) {
            case let .memberAccessExpr(syntax) where argument.label?.tokenKind == .predefined(.omit):
              return OmmitableTrait(stringLiteral: syntax.declName.baseName.text)

            case let .functionCallExpr(syntax):
              // TODO: Should this syntax be validated if it contains identifier("result")
              switch syntax.arguments.first?.expression.as(ExprSyntaxEnum.self) {
              case let .stringLiteralExpr(stringLiteralExprSyntax):
                switch stringLiteralExprSyntax.segments.first {
                case let .stringSegment(segment):
                  return OmmitableTrait(stringLiteral: segment.content.text)

                default:
                  return nil
                }

              default:
                return nil
              }

            default:
              return nil
            }
          }

        switch (tokenKind, arguments) {
        case let (.predefined(.Log), arguments):
          return if let arguments {
            .Log(arguments)
          } else {
            .Log()
          }

        case let (.predefined(.Omit) ,arguments):
          return if let arguments {
            .Omit(arguments)
          } else {
            .Omit()
          }

        default:
          return nil
        }

      default:
        return nil
      }
    }
  }
}

extension AttributeListSyntax.Element {
//  var loggableAttribute: LoggbleAttributeSyntax? {
//    guard
//      case let .attribute(attribute) = self,
//      let tokenKind = IdentifierTypeSyntax(attribute.attributeName)?.name.tokenKind
//    else { return nil }
//
//
//    switch tokenKind {
//    case .predefined(.Log):
//      return .Log
//
//    case .predefined(.Omit):
//      guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else { return .Omit() }
//
//      return .Omit(
//        arguments
//        .compactMap(LabeledExprListSyntax.init)
//        .compactMap { element in
//          element
//            .map(\.expression)
//            .compactMap(MemberAccessExprSyntax.init)
//            .compactMap(\.declName.baseName.text)
//            .map(LoggableTrait.init)
//        }.compactMap { $0 }
//      )
//
//    case .predefined(.Redact):
//      return .Redact
//
//    default:
//      return nil
//    }
//  }

  func `is`(_ tokenKind: TokenKind.Predefined) -> Bool {
    guard
      case let .attribute(attribute) = self,
      let identifierType = IdentifierTypeSyntax(attribute.attributeName)
    else { return false }

    return identifierType.name.tokenKind == tokenKind.identifer
  }

  var isLogged: Bool {
    guard
      case let .attribute(attribute) = self,
      let identifierType = IdentifierTypeSyntax(attribute.attributeName)
    else { return false }

    return identifierType.name.tokenKind == .predefined(.Logged)
  }

  var isLogOrOmitWithoutArgument: Bool {
    guard
      case let .attribute(attribute) = self,
      let identifierType = IdentifierTypeSyntax(attribute.attributeName)
    else { return false }

    return identifierType.name.tokenKind == .predefined(.Log)
      || identifierType.name.tokenKind == .predefined(.Omit)
      && attribute.arguments == nil

  }

  var isLoggableAttribute: Bool {
    guard
      case let .attribute(attribute) = self,
      let identifierType = IdentifierTypeSyntax(attribute.attributeName)
    else { return false }

    return identifierType.name.tokenKind == .predefined(.Log)
      || identifierType.name.tokenKind == .predefined(.Omit)
      || identifierType.name.tokenKind == .predefined(.Redact)
  }

  var isStatic: Bool {
    switch self {
    case let .attribute(attribute):
      guard let syntax = DeclModifierSyntax(attribute.attributeName)
      else { fallthrough }
      return syntax.name.tokenKind == .keyword(.static)

    default:
      return false
    }
  }
}
