import Loggable

struct Printer: Loggable {
  func emit(event: LoggableEvent) {
    let message = String(describing: event)
    print(message)
  }
  
  init() {}
}

extension Loggable where Self == Printer {
  static var printer: Printer { Printer() }
}
