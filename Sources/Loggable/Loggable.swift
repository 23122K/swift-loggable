import Foundation

public enum Loggable {
  public protocol Conformance: Sendable { // Emmiter (?)
    func emit(event: Event)
  }

  public enum Trait: Redactable, Ommitable {
    case _parameter(_ name: String)
    case _result
    case _parameters

    public init(rawValue: String) {
      switch rawValue {
      case ._parametersRawValue:
        self = ._parameters

      case ._resultRawValue:
        self = ._result

      default:
        self = ._parameter(rawValue)
      }
    }

    public var rawValue: String {
      switch self {
      case let ._parameter(name):
        return ._parameterRawValue(name)

      case ._result:
        return ._resultRawValue

      case ._parameters:
        return ._parametersRawValue
      }
    }
  }

  public struct Event {
    public var location: String
    public var declaration: String
    public var parameters: Dictionary<String, Any>
    public var result: Result<Any, any Error>

    public init(
      location: String,
      declaration: String,
      parameters: Dictionary<String, Any> = [:],
      result: Result<Any, any Error> = .success(())
    ) {
      self.location = location
      self.declaration = declaration
      self.parameters = parameters
      self.result = result
    }
  }
}

extension Redactable where Self == Loggable.Trait {
  public static func parameter(_ name: String) -> Self { ._parameter(name) }
  static public var result: Self { ._result }
}

extension Ommitable where Self == Loggable.Trait {
  public static func parameter(_ name: String) -> Self { ._parameter(name) }
  public static var parameters: Self { ._parameters }
  public static var result: Self { ._result }
}
