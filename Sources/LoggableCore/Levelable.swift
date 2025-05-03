public protocol Levelable: Trait {
  static func level(_: String) -> Self
}

public enum LevelableTrait: Levelable {
  case level(String)

  public init(stringLiteral value: StringLiteralType) {
    self = .level(value)
  }

  public var rawValue: StringLiteralType {
    switch self {
    case let .level(value):
      return .levelRawValue(value)
    }
  }
}

extension String: Levelable {
  public static func level(_ value: String) -> String {
    return .levelRawValue(value)
  }
}

extension Levelable where Self == StringLiteralType {}

extension String {
  fileprivate static func levelRawValue(_ value: String) -> String { "level_\(value)" }
}
