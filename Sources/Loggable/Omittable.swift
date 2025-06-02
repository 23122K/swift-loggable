public protocol Omittable: __Trait {
  static func parameter(_: String) -> Self
  static var __parameters: Self { get }
  static var __result: Self { get }
}

public enum Omit: Omittable {
  case parameter(_ name: String)
  case __result
  case __parameters

  public init(stringLiteral value: StringLiteralType) {
    switch value {
    case "__result":
      self = .__result

    case "__parameters":
      self = .__parameters

    default:
      self = .parameter(value)
    }
  }
}

extension Omittable where Self == Omit {
  public static var parameters: Self {
    Omit.__parameters
  }
  
  public static var result: Self {
    Omit.__result
  }
}

extension StringLiteralType: Omittable {
  public static func parameter(_ name: String) -> String {
    name
  }

  public static var __parameters: String {
    "__parameters"
  }

  public static var __result: String {
    "__result"
  }
}

extension Omittable where Self == StringLiteralType {}
