import OSLog
import LoggableCore

extension OSSignposter: Loggable {
  public func emit(event: LoggableEvent) {
    if let stringLiteral = event.level as? StringLiteralType {
      os_log(
        OSLogType(stringLiteral: stringLiteral),
        "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@\n→ Tags: %@",
        event.declaration, event.location, event.parameters, event.result.description, event.tags
      )
    } else {
      os_log(
        event.result.isSuccess ? .info : .error,
        "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@\n→ Tags: %@",
        event.declaration, event.location, event.parameters, event.result.description, event.tags
      )
    }
  }
}

extension Loggable where Self == OSSignposter {
  public static var signposter: Self { Self() }
}
