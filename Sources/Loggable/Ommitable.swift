public protocol Ommitable: Sendable, Equatable, RawRepresentable {
  static func _parameter(_ name: String) -> Self
  static var _parameters: Self { get }
  static var _result: Self { get }
}
//
//public enum OmmitableTrait: Ommitable {
//  case _parameter(_ name: String)
//  case _parameters
//  case _result
//
//  public init(rawValue: String) {
//    switch rawValue {
//    case ._parametersRawValue:
//      self = ._parameters
//
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
//    case ._parameters:
//      return ._parametersRawValue
//
//    case ._result:
//      return ._resultRawValue
//    }
//  }
//}
//
//extension Ommitable where Self == OmmitableTrait {
//  public static func parameter(_ name: String) -> Self { ._parameter(name) }
//  public static var parameters: Self { ._parameters }
//  public static var result: Self { ._result }
//}
