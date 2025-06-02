public protocol Taggable: Trait {
  associatedtype RawValue
  
  static func tag(_: RawValue) -> Self
}

extension String: Taggable {
  public static func tag(_ value: String) -> String {
    return value
  }
}

extension Taggable where Self == StringLiteralType {}
