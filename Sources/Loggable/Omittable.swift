/// A protocol describing a type that can be used to ignore
/// values from being captured upon function execution.
///
/// - Warning:
///   - `__parameters`
public protocol Omittable: __Trait {
  /// Represents and parameter name that will be ignored.
  static func parameter(_: String) -> Self
  
  /// A information to ignore all parameters and their arguments
  /// from beeing captured.
  static var __parameters: Self { get }
  
  /// A information to ignore result of a function.
  static var __result: Self { get }
}

public enum Omit: Omittable {
  /// Returns an instace of this type with associated value being a parameter name.
  ///
  /// - Parameter name: Represents **parameter name** not argument label.
  /// @Comment {
  ///   See https://docs.swift.org/swift-book/documentation/the-swift-programming-language/functions/#Function-Argument-Labels-and-Parameter-Names
  ///   for more information.
  /// }
  ///
  /// - Warning: Upon expansion, logged functions are stripped of their argument labels.
  case parameter(_ name: String)
  
  /// Signals to ignore result returned by a function.
  /// Errors thrown from the function are still captued.
  /// Do not pass this directly as a parameter. Use ``Omit.result``.
  case __result
  
  /// Signals to ignore arguments passed to a function upon execution.
  /// Do not pass this directly as a parameter. Use ``Omit.parameters``.
  case __parameters

  /// Initalizes an instance of this type from given string literal.
  ///
  /// - Parameter value: Parameter name to be ignored.
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
  /// All parameters and their arguments from attached
  /// function will not be captued.
  public static var parameters: Self {
    Omit.__parameters
  }
  
  /// A function result will be ignored upon function execution.
  /// Does not affect thrown errors, they will be still captured.
  public static var result: Self {
    Omit.__result
  }
}

/// Allows to pass string literal as a parameter name.
extension StringLiteralType: Omittable {
  /// Returns parameter name.
  ///
  /// - Parameter name: Represents **parameter name** not argument label.
  /// - Returns: Same parameter name passed as an argument.
  /// - Warning: Do not call this instance directly.
  @_spi(Private)
  public static func parameter(_ name: String) -> String {
    name
  }

  @_spi(Private)
  /// A static constat representing property name as string literal.
  /// Passing `"__parameters"` as an argument yields the same effect.
  public static var __parameters: String {
    "__parameters"
  }

  @_spi(Private)
  /// A static constat representing property name as string literal.
  /// Passing `"__result"` as an argument yields the same effect.
  public static var __result: String {
    "__result"
  }
}

extension Omittable where Self == StringLiteralType {}
