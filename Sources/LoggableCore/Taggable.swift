
public protocol Taggable: _Trait {
  static func _tag(_: String) -> Self
}

public enum TaggableTrait: Taggable {
  case _tag(String)

  public init(stringLiteral value: StringLiteralType) {
    self = ._tag(value)
  }
}

extension TaggableTrait: RawRepresentable {
  public init(rawValue: String) {
    self.init(stringLiteral: rawValue)
  }

  public var rawValue: String {
    switch self {
    case let ._tag(value):
      return value
    }
  }
}

extension String: Taggable {
  public static func _tag(_ value: String) -> String {
    ._tagRawValue(value)
  }
}

extension Taggable where Self == StringLiteralType {}

extension String {
  fileprivate static func _tagRawValue(_ value: String) -> String { #"tag_\(value)"# }
}
