public protocol Levelable: Trait {
  associatedtype RawValue
  
  static func level(_: RawValue) -> Self
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
