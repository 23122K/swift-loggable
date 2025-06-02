public protocol Levelable: __Trait {
  associatedtype RawValue
  
  static func level(_: RawValue) -> Self
}

extension String: Levelable {
  public static func level(_ value: String) -> String {
    value
  }
}

extension Levelable where Self == StringLiteralType {}
