import OSLog

public protocol Loggable: Sendable {
  func emit(event: LoggableEvent)
}

public protocol OSLogger {
  static var logger: Logger { get }
}

public struct LoggableEvent: CustomStringConvertible {
  public let level: (any Levelable)?
  public let location: String
  public let declaration: String
  public var parameters: Dictionary<String, Any>
  public var result: Result<Any, any Error>
  public let tags: Array<any Taggable>

  public var description: String {
    """
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
    parameters: Dictionary<String, Any> = [:],
    result: Result<Any, any Error> = .success(()),
    tags: Array<any Taggable> = []
  ) {
    self.level = level
    self.location = location
    self.declaration = declaration
    self.parameters = parameters
    self.result = result
    self.tags = tags
  }
}
