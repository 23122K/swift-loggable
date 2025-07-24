import Loggable

struct NSLogger: Loggable{
  func emit(event: LoggableEvent) {
    NSLog("NSLogger event emitted:\n%s", event.debugDescription)
  }
}

extension Loggable where Self == NSLogger {
  static var nsLog: NSLogger {
    NSLogger()
  }
}
