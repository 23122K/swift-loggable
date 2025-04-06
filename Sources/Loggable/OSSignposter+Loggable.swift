import OSLog
import LoggableCore

extension OSSignposter: Loggable {
  public func emit(event: LoggableEvent) {
    os_log(
      event.result.isSuccess ? .info : .error,
      "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@",
      event.declaration, event.location, event.parameters, event.result.description
    )
  }
}

extension Loggable where Self == OSSignposter {
  public static var signposter: Self { Self() }
}
