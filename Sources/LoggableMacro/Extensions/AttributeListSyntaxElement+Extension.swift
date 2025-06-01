import Foundation
import LoggableCore
import SwiftSyntax

extension ExprSyntaxProtocol {
  var parametersTrait: Bool {
    switch ExprSyntax(fromProtocol: self).as(ExprSyntaxEnum.self) {
    case let .memberAccessExpr(memberAccessExprSyntax):
      return memberAccessExprSyntax.declName.baseName.text == "parameters"
      
    default:
      return false
    }
  }
}

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
  /// Extract traits as expression syntax.
  ///
  /// Traits can be passed as to macros as either:
  ///   - ``StringLiteralExprSyntax``
  ///   -  ``MemberAccessExprSyntax``
  ///   - ``FunctionCallExprSyntax``
  ///  other ways should be regarded as invalid
  ///
  ///  - parameters:
  ///   - tokenKind: `Trait` macros does not use labeled parameters as they only
  ///     take one specific trait - in this case `tokenKind` should be `nil`.
  ///     When macro uses labeled parameter make sure `tokenKind` matches it.
  ///
  ///   - returns: ``ExprSyntax``
  func _extractTraitAsExprSyntax(
    withLabel tokenKind: TokenKind.Predefined? = nil
  ) -> (any ExprSyntaxProtocol)? {
    /// Checks whether all `elements` from`LabeledExprListSyntax` should be extracted.
    /// If tokenKind is provided, only `elements` with specified argument will be extracted.
    if let tokenKind, tokenKind.identifier != self.label?.tokenKind {
      return nil
    }
    
    switch self.expression.as(ExprSyntaxEnum.self) {
    case let .memberAccessExpr(memberAccessExprSyntax):
      return memberAccessExprSyntax

    case let .stringLiteralExpr(stringLiteralExprSyntax):
      return stringLiteralExprSyntax

    case let .functionCallExpr(functionCallExprSyntax):
      return functionCallExprSyntax

    default:
      return nil
    }
  }
  
}

extension LabeledExprListSyntax.Element {
  fileprivate func trait<T: Trait>(label tokenKind: TokenKind.Predefined? = nil) -> T? {
    if let tokenKind, tokenKind.identifier != self.label?.tokenKind { return nil }

    switch self.expression.as(ExprSyntaxEnum.self) {
    case let .memberAccessExpr(memberAccessExprSyntax):
      return T(stringLiteral: memberAccessExprSyntax.declName.baseName.text as! T.StringLiteralType)

    case let .stringLiteralExpr(stringLiteralExprSyntax):
      guard case let .stringSegment(stringLiteral) = stringLiteralExprSyntax.segments.first
      else { return nil }
      return T(stringLiteral: stringLiteral.content.text as! T.StringLiteralType)

    case let .functionCallExpr(functionCallExprSyntax):
      guard let expression = functionCallExprSyntax.arguments.first?.expression.as(ExprSyntaxEnum.self),
            case let .stringLiteralExpr(stringLiteralExprSyntax) = expression,
            case let .stringSegment(stringLiteral) = stringLiteralExprSyntax.segments.first
      else { return nil }
      return T(stringLiteral: stringLiteral.content.text as! T.StringLiteralType)

    default:
      return nil
    }
  }
}


extension AttributeListSyntax {
  /// Extracts all arguments passed as parameters to given annotation as well
  /// all arguments found in trait annotations.
  ///
  func extractAttributesFromAllAttachedAnnotations(
  ) -> [(annotation: TokenKind, attributes: LabeledExprListSyntax)] {
    self.compactMap { attribute -> (TokenKind, LabeledExprListSyntax)? in
      guard
        case let .attribute(attributeSyntax) = attribute,
        let tokenKind = IdentifierTypeSyntax(attributeSyntax.attributeName)?.name.tokenKind
      else { return nil }
      
      let arguments = LabeledExprListSyntax(attributeSyntax.arguments) ?? []
      return (tokenKind, arguments)
    }
  }
  
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
  
  func extractTraits(for label: TokenKind.Predefined) -> [any ExprSyntaxProtocol] {
    self.extractAttributesFromAllAttachedAnnotations()
      .flatMap { annotation, attributes -> [any ExprSyntaxProtocol] in
        switch annotation {
          case .predefined(.Tag) where label == .tag:
            return attributes.map(\.expression)
            
          case .predefined(.Omit) where label == .omit:
            return attributes.map(\.expression)
            
          case .predefined(.Level) where label == .level:
            return attributes.map(\.expression)
            
          case .predefined(.Log), .predefined(.OSLog):
            return attributes
              .extractVariadicArguments(for: label)
              .map(\.expression)
            
          default:
            return []
        }
      }
  }
}

extension LabeledExprListSyntax {
  /// Extract arguments passed to variadic parameter.
  ///
  /// - parameters:
  ///   - label: Variadic parameter label that preceeds arguments.
  ///
  /// - returns:
  ///   - `LabeledExprListSyntax` that contains only arguments from specified
  ///      parameter label.
  ///
  func extractVariadicArguments(for label: TokenKind.Predefined) -> LabeledExprListSyntax {
    /// Find the start index of element with label that matches one passed as argument
    guard let startIndex = self.firstIndex(
      where: { $0.label?.tokenKind == label.identifier }
    ) else {
      return []
    }

    /// Create a range thats starts after `startIndex`, otherwise `startIndex`
    /// would be classified as `endIndex` too
    let range = self.index(after: startIndex)...
    
    /// Check for any other vardict parameter lables that might come after specifed one
    /// If non found, end of arguments is reached
    let endIndex = self[range].firstIndex { $0.label != nil } ?? self.endIndex

    /// Return the slice from `startIndex` up to (but not including) `endIndex`
    return LabeledExprListSyntax(self[startIndex..<endIndex])
  }
}
