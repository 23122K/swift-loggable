import Foundation
import LoggableCore
import SwiftSyntax

enum TraitSyntax {
  case Log(
    level: LevelableTrait?,
    ommitable: [OmittableTrait],
    taggable: [TaggableTrait]
  )

  case OSLog(
    level: LevelableTrait?,
    ommitable: [OmittableTrait],
    taggable: [TaggableTrait]
  )

  case Level(LevelableTrait?)
  case omit([OmittableTrait])
  case tag([TaggableTrait])
}

extension Array where Element == TraitSyntax {
  var level: LevelableTrait? {
    for trait in self {
      switch trait {
      case let .OSLog(level, _, _):
        return level

      case let .Log(level, _, _):
        return level

      case let .Level(level):
        return level

      default:
        break
      }
    }
    return nil
  }

  var ommitable: [OmittableTrait] {
    var result: Set<OmittableTrait> = []
    for trait in self {
      switch trait {
      case let .Log(_, traits, _):
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
      case let .Log(_, _, traits):
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
      /// should be implemented it suports traits that conform to``Omittable`` and ``Taggable``
      case .predefined(.Log), .predefined(.OSLog):
        return .Log(
          level: arguments.first?.trait(label: .level),
          ommitable: arguments.compactMap { argument in
            argument.trait(label: .omit)
          },
          taggable: arguments.compactMap { argument in
            argument.trait(label: .tag)
          }
        )

      case .predefined(.Tag):
        return .tag(
          arguments.compactMap { argument in
            argument.trait()
          }
        )

      case .predefined(.Level):
        return .Level(
          arguments.first?.trait()
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
