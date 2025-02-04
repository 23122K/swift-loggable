import Foundation
import OSLog

open class Loggable: @unchecked Sendable {
  public static let `default` = Loggable()
  
  open func log(location: String, of declaration: String) {
    os_log(.info, "→ Function: %@\n→ Location: %@", declaration, location)
  }
  
  open func log(parameters: Any) {
    print(parameters)
  }
  
  open func log(error: Error) {
    os_log(.error, "→ Error: %@", "\(error)")
  }
  
  open func log(result: Any) {
    os_log(.info, "→ Result: %@", "\(result)")
  }
  
  public init() { }
}
