import LoggableCore
import OSLog

extension OSSignposter: Loggable {
  public func emit(event: LoggableEvent) {
    if let stringLiteral = event.level as? StringLiteralType {
      os_log(
        OSLogType(stringLiteral: stringLiteral),
        "%@",
        event.description
      )
    } else {
      os_log(
        event.result.isSuccess ? .info : .error,
        "%@",
        event.description
      )
    }
  }
}

extension Loggable where Self == OSSignposter {
  public static var signposter: Self { Self() }
}
