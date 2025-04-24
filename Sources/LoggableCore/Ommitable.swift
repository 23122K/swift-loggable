
public protocol Ommitable: _Trait {
  static func parameter(_: String) -> Self
  static var _parameters: Self { get }
  static var _result: Self { get }
}

public enum OmmitableTrait: Ommitable {
  case parameter(_ name: String)
  case _result
  case _parameters

  public init(stringLiteral value: StringLiteralType) {
    switch value {
    case ._resultRawValue:
      self = ._result

    case ._parametersRawValue:
      self = ._parameters

    default:
      self = .parameter(value)
    }
  }
}

extension Ommitable where Self == OmmitableTrait {
  public static var parameters: Self { ._parameters }
  public static var result: Self { ._result }
}

extension StringLiteralType: Ommitable {
  public static func parameter(_ name: String) -> String {
    .parameterRawValue(name)
  }

  public static var _parameters: String {
    ._parametersRawValue
  }

  public static var _result: String {
    ._resultRawValue
  }
}

extension Ommitable where Self == StringLiteralType {}

extension String {
  fileprivate static func parameterRawValue(_ name: String) -> String { "parameter_\(name)" }
  fileprivate static let _parametersRawValue = #"_parameters"#
  fileprivate static let _resultRawValue = #"_result"#
}
