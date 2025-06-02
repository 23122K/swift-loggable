#if canImport(OSLog)
@_exported public import OSLog
#endif

extension Logger: Loggable {
  public func emit(event: LoggableEvent) {
    if let level = event.level as? OSLogType {
      self.log(level: level, "\(String(describing: event))")
    } else {
      self.log(level: event.result.isSuccess ? .info : .error, "\(String(describing: event))")
    }
  }
}

extension Loggable where Self == Logger {
  public static var logger: Self { Logger() }
}

extension Result {
  fileprivate var isSuccess: Bool {
    guard case .success = self
    else { return false }
    return true
  }
}
