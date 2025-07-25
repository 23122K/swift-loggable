/// A protocol describing a type used to express the level of an event.
///
/// A type should confrom to this protocol if it represents logging level.
///
/// @Comment {
///   The most common way to express a logging level is by using an enumeration.
///   Therefore, the recommended way to conform to `Levelable` is by using one.
/// }
public protocol Levelable: __Trait {
  /// The type of the associated value used to represent a logging level.
  associatedtype RawValue
  
  /// Returns the logging level for the given value.
  ///
  /// - Parameter value: The value associated with the logging level.
  ///
  /// - Returns: An instance representing the corresponding logging level.
  static func level(_ value: RawValue) -> Self
}

extension String: Levelable {
  /// Returns the logging level represented by the given string literal.
  ///
  /// - Parameter value: A string representing the logging level.
  ///
  /// - Returns: The same string value passed as the parameter.
  public static func level(_ value: String) -> String {
    value
  }
}

extension Levelable where Self == StringLiteralType {}
