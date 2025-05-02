public protocol Taggable: _Trait {
  static func tag(_: String) -> Self
}

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
