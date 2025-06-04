/// An enumeration that defines access levels.
///
/// @Comment {
///   See https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol/
///   for additional information.
/// }
public enum __AccessLevelModifier: Taggable {
  /// A string literal representation of access level keyword.
  case tag(StringLiteralType)
  
  /// Initialize an instance of this type that represents Swift access level.
  ///
  /// Currently, `__AccessLevelModifier` is only extracted
  /// as a `MemberAccessExprSyntax`.
  /// When declaring a new instance, ensure that both the tag’s associated value
  /// and its property name matches matches the keyword.
  ///
  /// - Parameter value: A string literal that must match a Swift access level
  ///   keyword (e.g. "public", "private").
  @_spi(Experimental)
  public init(stringLiteral value: StringLiteralType) {
    self = __AccessLevelModifier.tag(value)
  }
}

extension Taggable where Self == __AccessLevelModifier {
  /// A `public` access level modifier.
  public static var `public`: __AccessLevelModifier {
    __AccessLevelModifier(stringLiteral: "public")
  }
  
  /// An `internal` access level modifier.
  public static var `internal`: __AccessLevelModifier {
    __AccessLevelModifier(stringLiteral: "internal")
  }
  
  /// A `fileprivate` access level modifier.
  public static var `fileprivate`: __AccessLevelModifier {
    __AccessLevelModifier(stringLiteral: "fileprivate")
  }
  
  /// A `private` access level modifier.
  public static var `private`: __AccessLevelModifier {
    __AccessLevelModifier(stringLiteral: "private")
  }
}
