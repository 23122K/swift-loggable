import LoggableCore
import OSLog

extension OSLogType: @retroactive ExpressibleByStringLiteral {}
extension OSLogType: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension OSLogType: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension OSLogType: @retroactive @unchecked Sendable {}
extension OSLogType: @retroactive Hashable {}
extension OSLogType: Taggable {
  public static func _tag(_ value: String) -> OSLogType {
    value.osLogType
  }

  public init(stringLiteral value: StringLiteralType) {
    self = value.osLogType
  }
}

extension Taggable where Self == OSLogType {
  public static var `default`: Self { .default }
  public static var debug: Self { .debug }
  public static var fault: Self { .fault }
  public static var error: Self { .error }
  public static var info: Self { .info }

  func implicit() -> OSLogType {
    switch self {
    case .debug:
      return .debug

    case .info:
      return .info

    case .fault:
      return .fault

    case .error:
      return .error

    default:
      return .default
    }
  }
}

extension Logger: Loggable {
  public func emit(event: LoggableEvent) {
    if let stringLiteral = event.tags.first as? StringLiteralType {
      self.log(level: OSLogType(stringLiteral: stringLiteral), "\(event.location)")
    } else {
      self.log(level: event.result.isSuccess ? .info : .error, "\(event.location)")
    }
  }
}

extension String {
  private static let debug = "debug"
  private static let info = "info"
  private static let fault = "fault"
  private static let error = "error"

  fileprivate var osLogType: OSLogType {
    switch self {
    case .debug:
      return .debug

    case .info:
      return .info

    case .fault:
      return .fault

    case .error:
      return .error

    default:
      return .default
    }
  }
}

