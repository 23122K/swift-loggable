import Foundation
import SwiftSyntax

extension ExprSyntaxProtocol {
  var isOmitParameters: Bool {
    switch ExprSyntax(fromProtocol: self).as(ExprSyntaxEnum.self) {
      case let .memberAccessExpr(memberAccessExprSyntax):
        return memberAccessExprSyntax.declName.baseName.text == "parameters"
        
      case let .stringLiteralExpr(stringLiteralExprSynta):
        return stringLiteralExprSynta.isEqual(to: "__parameters")
        
      default:
        return false
    }
  }
  
  var isOmitResult: Bool {
    switch ExprSyntax(fromProtocol: self).as(ExprSyntaxEnum.self) {
      case let .memberAccessExpr(memberAccessExprSyntax):
        return memberAccessExprSyntax.declName.baseName.text == "result"
        
      case let .stringLiteralExpr(stringLiteralExprSyntax):
        return stringLiteralExprSyntax.isEqual(to: "__result")
        
      default:
        return false
    }
  }
  
  func isOmitParameter(_ label: TokenSyntax) -> Bool {
    switch ExprSyntax(fromProtocol: self).as(ExprSyntaxEnum.self) {
      case let .memberAccessExpr(memberAccessExprSyntax):
        return memberAccessExprSyntax.declName.baseName.tokenKind == label.tokenKind
        
      case let .stringLiteralExpr(stringLiteralExprSynta):
        return stringLiteralExprSynta.isEqual(to: label.text)
        
      default:
        return false
    }
  }
}

extension StringLiteralExprSyntax {
  fileprivate func isEqual(to text: String) -> Bool {
    switch self.segments.first {
      case let .stringSegment(stringSegmentSyntax):
        return stringSegmentSyntax.content.trimmedDescription == text
        
        
      default:
        return false
    }
  }
}

extension AttributeListSyntax {
  /// Extracts all arguments passed as parameters to given annotation as well
  /// all arguments found in trait annotations.
  ///
  var attributesFromAllAttachedAnnotations: [(TokenKind, LabeledExprListSyntax)] {
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
    self.attributesFromAllAttachedAnnotations
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
