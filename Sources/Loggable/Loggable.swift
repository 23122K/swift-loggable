#if canImport(OSLog)
@_exported public import OSLog
#endif

/// A protocol that provides instances of conforming types with the ability to
/// handle emitted events.
public protocol Loggable: Sendable {
  /// Handle an emitted event.
  ///
  /// Events are currently emitted in the following cases:
  ///   - When the function completes successfully
  ///   - When the function throws an error.
  ///
  func emit(event: LoggableEvent)
}

// TODO: 23122K - Make this type conform to Sendable and use CustomDebugStringConvertible
/// A type representing captured metadata from an invoked function.
public struct LoggableEvent: CustomStringConvertible, CustomDebugStringConvertible {
  /// The logging level associated with the event.
  public let level: (any Levelable)?

  /// The source location of the invoked function.
  public let location: String

  /// A representation of a function's name and return
  /// type, excluding parameters and body.
  public let declaration: String

  /// A set of arguments passed to a function, associated
  /// with their parameter labels.
  public var parameters: [String: Any]

  /// The result of the function.
  public var result: Result<Any, any Error>

  /// The collection of tags associated with the event.
  public let tags: [any Taggable]

  public var description: String {
    """
    location: \(location)
    declaration: \(declaration)
    parameters: \(parameters)
    result: \(result)
    tags: \(tags)
    """
  }

  public var debugDescription: String {
    """
    level: \(String(describing: level))
    location: \(location)
    declaration: \(declaration)
    parameters: \(parameters)
    result: \(result)
    tags: \(tags)
    """
  }

  /// Initializes an instance that aggregates metadata captured at
  /// the time of function invocation.
  ///
  /// - Parameters:
  ///   - level: The logging level at which the event should be emitted.
  ///   - location: The source location where the function was invoked.
  ///   - declaration: The function signature of the invoked function.
  ///   - parameters: The set of parameters and their corresponding argument values.
  ///   - result: The result returned by the function.
  ///   - tags: A collection of tags to associate with the event.
  public init(
    level: (any Levelable)? = nil,
    location: String,
    declaration: String,
    parameters: [String: Any] = [:],
    result: Result<Any, any Error> = .success(()),
    tags: [any Taggable] = []
  ) {
    self.level = level
    self.location = location
    self.declaration = declaration
    self.parameters = parameters
    self.result = result
    self.tags = tags
  }
}

// TODO: 23122K - Consider using swift-log as a fallback when not running on Apple platforms
/// A default `Loggable` implementation that
/// uses a ``Logger`` instance to log to the default subsystem.
public struct LoggableLogger: Loggable {
  /// The logger instance used for logging.
  let logger: Logger

  /// Logs captured event metadata to the default subsystem.
  ///
  /// The event’s logging level is inherited from the function result unless explicitly specified:
  /// - ``OSLogType.info`` for successful function executions.
  /// - ``OSLogType.error`` for functions that throw errors.
  public func emit(event: LoggableEvent) {
    self.logger.emit(event: event)
  }

  @_spi(Experimental)
  /// Creates a new instance of this type to serve as the default handler
  /// for emitted events.
  ///
  /// Unless a custom logger is explicitly specified, this instance handles
  /// events emitted from:
  /// - ``Log(using:)
  /// - ``Log(using:level:omit:tag:)``
  ///
  /// - Parameter logger: Logger used to log captured metadata.
  public init(logger: Logger = Logger()) {
    self.logger = logger
  }
}

extension Loggable where Self == LoggableLogger {
  /// A default loggable instance. Logs to default subsystem.
  public static var logger: Self { LoggableLogger() }
}

extension Logger: Loggable {
  public func emit(event: LoggableEvent) {
    if let level = event.level as? OSLogType {
      self.log(level: level, "\(String(describing: event))")
    } else {
      self.log(level: event.result.isSuccess ? .info : .error, "\(String(describing: event))")
    }
  }
}

extension Result {
  fileprivate var isSuccess: Bool {
    guard case .success = self
    else { return false }
    return true
  }
}
