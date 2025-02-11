import Foundation
import OSLog

open class Loggable: @unchecked Sendable {
  public static let `default` = Loggable()

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
