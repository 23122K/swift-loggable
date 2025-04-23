public protocol Levelable: _Trait {
  static func _level(_: String) -> Self
}

public enum LevelableTrait: Levelable {
  case _level(String)

  public init(stringLiteral value: StringLiteralType) {
    self = ._level(value)
  }

  public var rawValue: StringLiteralType {
    switch self {
    case let ._level(value):
      return.levelRawValue(value)
    }
  }
}

extension String: Levelable {
  public static func _level(_ value: String) -> String {
    return .levelRawValue(value)
  }
}

extension Levelable where Self == StringLiteralType {}

extension String {
  fileprivate static func levelRawValue(_ value: String) -> String { "level_\(value)" }
}
