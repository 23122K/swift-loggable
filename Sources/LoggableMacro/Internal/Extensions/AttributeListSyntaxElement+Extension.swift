import Foundation
import LoggableCore
import SwiftSyntax

enum TraitSyntax {
  case log(ommitable: [OmmitableTrait], taggable: [TaggableTrait])
  case tag([TaggableTrait])
  case omit([OmmitableTrait])
}

extension Array where Element == TraitSyntax {
  var ommitable: [OmmitableTrait] {
    var result: Set<OmmitableTrait> = []
    for trait in self {
      switch trait {
      case let .log(traits, _):
        result = result.union(traits)

      case let .omit(traits):
        result = result.union(traits)

      default:
        break
      }
    }

    return result.sorted { $0.hashValue < $1.hashValue }
  }

  var taggable: [TaggableTrait] {
    var result = Set<TaggableTrait>()
    for trait in self {
      switch trait {
      case let .log(_, traits):
        result = result.union(traits)

      case let .tag(traits):
        result = result.union(traits)

      default:
        break
      }
    }

    return result.sorted { $0.hashValue < $1.hashValue }
  }
}

extension LabeledExprListSyntax.Element {
  fileprivate func trait<Trait: _Trait>(label tokenKind: TokenKind.Predefined? = nil) -> Trait? {
    if let tokenKind, tokenKind.identifer != self.label?.tokenKind { return nil }

    switch self.expression.as(ExprSyntaxEnum.self) {
    case let .memberAccessExpr(memberAccessExprSyntax):
      return Trait(stringLiteral: memberAccessExprSyntax.declName.baseName.text as! Trait.StringLiteralType)

    case let .stringLiteralExpr(stringLiteralExprSyntax):
      guard case let .stringSegment(stringLiteral) = stringLiteralExprSyntax.segments.first
      else { return nil }
      return Trait(stringLiteral: stringLiteral.content.text as! Trait.StringLiteralType)

    case let .functionCallExpr(functionCallExprSyntax):
      guard let expression = functionCallExprSyntax.arguments.first?.expression.as(ExprSyntaxEnum.self),
            case let .stringLiteralExpr(stringLiteralExprSyntax) = expression,
            case let .stringSegment(stringLiteral) = stringLiteralExprSyntax.segments.first
      else { return nil }
      return Trait(stringLiteral: stringLiteral.content.text as! Trait.StringLiteralType)

    default:
      return nil
    }
  }
}

extension AttributeListSyntax {
  var attached: [(TokenKind, LabeledExprListSyntax)] {
    self.compactMap { element -> (TokenKind, LabeledExprListSyntax)? in
      guard
        case let .attribute(attributeSyntax) = element,
        let tokenKind = IdentifierTypeSyntax(attributeSyntax.attributeName)?.name.tokenKind
      else { return nil }

      let arguments = LabeledExprListSyntax(attributeSyntax.arguments) ?? []
      return (tokenKind, arguments)
    }
  }

  /// Extracts passed attributes found ``AttributeListSyntax`` and assigns them per annotation
  ///
  ///  - Returns:
  func parsableTraitSyntax() -> [TraitSyntax] {
    /// - Parameter source: Indicates to what annotation arguments has been passed,
    /// - Parameter arguments: ``LabeledExprListSyntax``
    /// - Returns: A new collection with the new layout underlying it.
    self.attached.compactMap { source, arguments in
      switch source {
      /// ``@Log`` macro itself does not has any traits, however due to some doubts about how ``BodyMacro``
      /// should be implemented it suports traits that conform to``Ommitable`` and ``Taggable``
      case .predefined(.Log):
        return .log(
          ommitable: arguments.compactMap { argument in
            argument.trait(label: .omit)
          },
          taggable: arguments.compactMap { argument in
            argument.trait(label: .tag)
          }
        )

      case .predefined(.Tag), .predefined(.OSLog):
        return .tag(
          arguments.compactMap { argument in
            argument.trait()
          }
        )

      case .predefined(.Omit):
        return .omit(
          arguments
            .compactMap { argument in
            argument.trait()
          }
        )

      default:
        return nil
      }
    }
  }
}

extension AttributeListSyntax.Element {

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
      || identifierType.name.tokenKind == .predefined(.Tag)
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
