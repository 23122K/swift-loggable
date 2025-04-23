public protocol Taggable: _Trait {
  static func _tag(_: String) -> Self
}

public enum TaggableTrait: Taggable {
  case _tag(String)

  public init(stringLiteral value: StringLiteralType) {
    self = ._tag(value)
  }

  public var rawValue: StringLiteralType {
    switch self {
    case let ._tag(value):
      return ._tagRawValue(value)
    }
  }
}

extension String: Taggable {
  public static func _tag(_ value: String) -> String {
    return ._tagRawValue(value)
  }
}

extension Taggable where Self == StringLiteralType {}

extension String {
  fileprivate static func _tagRawValue(_ value: String) -> String { "tag_\(value)" }
}
