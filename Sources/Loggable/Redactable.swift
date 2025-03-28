public protocol Redactable: Sendable, Equatable, RawRepresentable {
  static func _parameter(_ name: String) -> Self
  static var _result: Self { get }
}
//
//public enum RedactableTrait: Redactable {
//  case _parameter(_ name: String)
//  case _result
//
//  public init(rawValue: String) {
//    switch rawValue {
//    case ._resultRawValue:
//      self = ._result
//
//    default:
//      self = ._parameter(rawValue)
//    }
//  }
//
//  public var rawValue: String {
//    switch self {
//    case let ._parameter(name):
//      return ._parameterRawValue(name)
//
//    case ._result:
//      return ._resultRawValue
//    }
//  }
//}
//
//extension Redactable where Self == RedactableTrait {
//  static func parameter(_ name: String) -> Self { ._parameter(name) }
//  static var result: Self { ._result }
//}
