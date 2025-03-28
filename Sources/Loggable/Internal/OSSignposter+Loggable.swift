import OSLog

extension OSSignposter: Loggable.Conformance {
  public func emit(event: Loggable.Event) {
    os_log(
      event.result.isSuccess ? .info : .error,
      "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@",
      event.declaration, event.location, event.parameters, event.result.description
    )
  }
}

extension Loggable.Conformance where Self == OSSignposter {
  public static var signposter: Self { Self() }
}
