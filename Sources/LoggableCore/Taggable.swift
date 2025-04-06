
public protocol Taggable: Sendable, Equatable, ExpressibleByStringLiteral {
  static func _tag(_ value: String) -> Self
}

public enum TaggableTrait: Taggable {
  case _tag(String)

  public init(stringLiteral value: StringLiteralType) {
    self = ._tag(value)
  }
}

extension String: Taggable {
  public static func _tag(_ value: String) -> String {
    ._tagRawValue(value)
  }
}

extension Taggable where Self == StringLiteralType {}
