#if canImport(OSLog)
@_exported public import OSLog
#endif

public protocol Loggable: Sendable {
  func emit(event: LoggableEvent)
}

public protocol OSLogger {
  static var logger: Logger { get }
}

public struct LoggableEvent: CustomStringConvertible, CustomDebugStringConvertible {
  public let level: (any Levelable)?
  public let location: String
  public let declaration: String
  public var parameters: [String: Any]
  public var result: Result<Any, any Error>
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
    level: \(level)
    location: \(location)
    declaration: \(declaration)
    parameters: \(parameters)
    result: \(result)
    tags: \(tags)
    """
  }

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
