public protocol Taggable: __Trait {
  associatedtype RawValue
  
  static func tag(_: RawValue) -> Self
}

extension String: Taggable {
  public static func tag(_ value: String) -> String {
    value
  }
}

extension Taggable where Self == StringLiteralType {}
