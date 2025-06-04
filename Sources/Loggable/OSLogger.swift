#if canImport(OSLog)
@_exported public import OSLog
#endif

/// A protocol that defines a type providing a static instance of ``Logger``.
///
/// Type annotated with the `OSLogger` macro implicitly conform to this protocol.
public protocol OSLogger {
  /// A static logger instance associated with the conforming type.
  ///
  /// Requred by ``OSLogger(access:subsystem:category:)`` macro.
  static var logger: Logger { get }
}
