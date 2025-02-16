import Foundation
import OSLog

open class Loggable: @unchecked Sendable {
  public static let `default` = Loggable()

  public struct Event {
    public var location: String
    public var declaration: String
    public var result: Result<Any, any Error>
    public var parameters: [Any]

    public init(
      location: String,
      declaration: String,
      result: Result<Any, any Error> = .success(()),
      parameters: [Any] = []
    ) {
      self.location = location
      self.declaration = declaration
      self.result = result
      self.parameters = parameters
    }
  }

  open func emit(event: Event) {
    print("Event")
    print(event.result)
  }

  open func log(at location: String, of declaration: String) {
    os_log(.info, "→ Function: %@\n→ Location: %@", declaration, location)
  }

  open func log(at location: String, of declaration: String, result: Any) {
    os_log(
      .info,
      "→ Function: %@\n→ Location: %@\n→ Result: %@",
      declaration, location, "\(result)"
    )
  }

  open func log(at location: String, of declaration: String, error: any Error) {
    os_log(
      .error,
      "→ Function: %@\n→ Location: %@\n→ Error: %@",
      declaration, location, "\(error)"
    )
  }

  public init() {}
}

extension Result {
  var isSuccess: Bool {
    guard case .success = self
    else { return false }
    return true
  }

  var description: String {
    switch self {
    case let .success(value):
      return "\(value)"

    case let .failure(error):
      return "\(error)"
    }
  }
}
