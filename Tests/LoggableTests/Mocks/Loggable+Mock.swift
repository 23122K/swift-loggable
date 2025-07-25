import Loggable

final class MockLogger: Loggable, @unchecked Sendable {
  var events: [LoggableEvent]
  
  func emit(event: LoggableEvent) {
    self.events.append(event)
  }
  
  init(events: [LoggableEvent] = []) {
    self.events = events
  }
}

extension Loggable where Self == MockLogger {
  static var mock: any Loggable {
    MockLogger()
  }
}
