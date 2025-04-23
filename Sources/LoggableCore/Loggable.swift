import OSLog

public protocol Loggable: Sendable {
  func emit(event: LoggableEvent)
}

public struct LoggableEvent: CustomStringConvertible {
  public var location: String
  public var declaration: String
  public var parameters: Dictionary<String, Any>
  public var result: Result<Any, any Error>
  public var tags: Array<any Taggable>

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
    location: String,
    declaration: String,
    parameters: Dictionary<String, Any> = [:],
    result: Result<Any, any Error> = .success(()),
    tags: Array<any Taggable> = []
  ) {
    self.location = location
    self.declaration = declaration
    self.parameters = parameters
    self.result = result
    self.tags = tags
  }
}
