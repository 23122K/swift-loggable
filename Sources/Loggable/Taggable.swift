/// A protocol representing a value that can be used to modify
/// ``LoggableEvent`` values at pre-expansion time.
///
/// A type should implement this protocol if it represents
/// common logic or a way to customize behavior of
/// captured event.
public protocol Taggable: __Trait {
  /// The type of the associated value used to represent a tag.
  associatedtype RawValue = StringLiteralType
  
  /// Returns a instance representing a tag.
  ///
  /// - Parameter value: Represents value associated with tag.
  ///
  /// - Returns: An instance representing the corresponding tag.
  static func tag(_ value: RawValue) -> Self
}

extension String: Taggable {
  /// Creates a `Taggable` instance from given string literal.
  ///
  /// - Parameter value: String representing a tag.
  ///
  /// - Returns: Value passed as a parameter.
  public static func tag(_ value: String) -> String {
    value
  }
}

extension Taggable where Self == StringLiteralType {}
