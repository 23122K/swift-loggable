import Foundation
import OSLog

public protocol Loggable {
  func emit(event: Event)
}

extension OSSignposter: Loggable {
  public func emit(event: Event) {
    os_log(
      event.result.isSuccess ? .info : .error,
      "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@",
      event.declaration, event.location, event.parameters, event.result.description
    )
  }
}

extension Loggable where Self == OSSignposter {
  public static var signposter: Self { Self() }
}

public struct Event {
  public var location: String
  public var declaration: String
  public var parameters: Dictionary<String, Any>
  public var result: Result<Any, any Error>

  public init(
    location: String,
    declaration: String,
    parameters: Dictionary<String, Any> = [:],
    result: Result<Any, any Error> = .success(())
  ) {
    self.location = location
    self.declaration = declaration
    self.parameters = parameters
    self.result = result
  }
}


//open class Loggable: @unchecked Sendable {
//  public static let `default` = Loggable()
//
//  public struct Event {
//    public var location: String
//    public var declaration: String
//    public var parameters: Dictionary<String, Any>
//    public var result: Result<Any, any Error>
//
//    public init(
//      location: String,
//      declaration: String,
//      parameters: Dictionary<String, Any> = [:],
//      result: Result<Any, any Error> = .success(())
//    ) {
//      self.location = location
//      self.declaration = declaration
//      self.parameters = parameters
//      self.result = result
//    }
//  }
//
//  open func emit(event: Event) {
//    os_log(
//      event.result.isSuccess ? .info : .error,
//      "→ Function: %@\n→ Location: %@\n→ Parameters: %@\n→ Result: %@",
//      event.declaration, event.location, event.parameters, event.result.description
//    )
//  }
//
//  public init() {}
//}
