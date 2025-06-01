public protocol Taggable: Trait {
  static func tag(_: String) -> Self
}

///// A protocol describing tag that can be passed to ``@Tag`` or  ``@Loggable``
///// macros in order to tailor behaviour after capturing ``LoggableEvent``.
/////
///// - warning: To not conform to this protocol directly.
//private protocol _Taggable: Trait {
//  /// Returns specified tag.
//  ///
//  /// - parameters:
//  ///   - value: Value associated with tag.
//  ///
//  /// - returns: Self
//  static func tag(_ value: String) -> Self
//}
//
//public enum _TaggableTrait: _Taggable {
//  case tag(String)
//
//  
//  public init(stringLiteral value: StringLiteralType) {
//    self = .tag(value)
//  }
//
//  public var rawValue: StringLiteralType {
//    switch self {
//    case let .tag(value):
//      return .tagRawValue(value)
//    }
//  }
//}


public enum TaggableTrait: Taggable {
  case tag(String)

  public init(stringLiteral value: StringLiteralType) {
    self = .tag(value)
  }

  public var rawValue: StringLiteralType {
    switch self {
    case let .tag(value):
      return .tagRawValue(value)
    }
  }
}

extension String: Taggable {
  public static func tag(_ value: String) -> String {
    return .tagRawValue(value)
  }
}

extension Taggable where Self == StringLiteralType {}

extension String {
  fileprivate static func tagRawValue(_ value: String) -> String { "tag_\(value)" }
}
