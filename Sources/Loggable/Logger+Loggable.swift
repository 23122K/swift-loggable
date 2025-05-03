import LoggableCore
import OSLog

extension Logger: Loggable {
  public func emit(event: LoggableEvent) {
    if let stringLiteral = event.level as? StringLiteralType {
      self.log(level: OSLogType(stringLiteral: stringLiteral), "\(event.description)")
    } else {
      self.log(level: event.result.isSuccess ? .info : .error, "\(event.description)")
    }
  }
}

extension Loggable where Self == Logger {
  public static var logger: Self { Logger() }
}

extension Result {
  var isSuccess: Bool {
    guard case .success = self
    else { return false }
    return true
  }
}
