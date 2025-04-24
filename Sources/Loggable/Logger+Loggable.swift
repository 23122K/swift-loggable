import LoggableCore
import OSLog

extension OSLogType: @retroactive ExpressibleByStringLiteral {}
extension OSLogType: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension OSLogType: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension OSLogType: @retroactive @unchecked Sendable {}
extension OSLogType: @retroactive Hashable {}
extension OSLogType: Levelable {
  public static func level(_ value: String) -> OSLogType {
    value.osLogType
  }

  public init(stringLiteral value: StringLiteralType) {
    self = value.osLogType
  }
}

extension Levelable where Self == OSLogType {
  public static var `default`: Self { .level("default") }
  public static var debug: Self { .level("debug") }
  public static var fault: Self { .level("fault") }
  public static var error: Self { .level("error") }
  public static var info: Self { .level("info") }
}

extension Logger: Loggable {
  public func emit(event: LoggableEvent) {
    if let stringLiteral = event.level as? StringLiteralType {
      self.log(level: OSLogType(stringLiteral: stringLiteral), "\(event.description)")
    } else {
      self.log(level: event.result.isSuccess ? .info : .error, "\(event.description)")
    }
  }
}

extension String {
  private static let `default` = "level_default"
  private static let debug = "level_debug"
  private static let info = "level_info"
  private static let fault = "level_fault"
  private static let error = "level_error"

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

    case .default:
      return .default

    default:
      return .default
    }
  }
}
