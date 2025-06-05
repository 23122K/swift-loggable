#if canImport(OSLog)
import struct OSLog.OSLogType
#endif

extension OSLogType: @retroactive ExpressibleByStringLiteral {}
extension OSLogType: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension OSLogType: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension OSLogType: @retroactive @unchecked Sendable {}
extension OSLogType: @retroactive Hashable {}
extension OSLogType: Levelable {
  /// Creates an instance of ``OSLogType`` from its raw value.
  public static func level(_ value: UInt8) -> OSLogType {
    OSLogType(value)
  }

  /// Intializes an instace of ``OSLogType`` from the string literal.
  ///
  /// - Parameter value: String literal that must match the name
  ///   of defines properties. Defaults to `OSLogType.default` when
  ///   invalid value is provided.
  public init(stringLiteral value: StringLiteralType) {
    switch value {
      case "debug":
        self = OSLogType.debug
        
      case "default":
        self = OSLogType.default
        
      case "fault":
        self = OSLogType.fault
        
      case "error":
        self = OSLogType.error
        
      case "info":
        self = OSLogType.info
        
      default:
        self = OSLogType.default
    }
  }
}

extension Levelable where Self == OSLogType {
  /// A `default` OSLogType level.
  public static var `default`: Self {
    OSLogType.default
  }
  
  /// A `debug` OSLogType level.
  public static var debug: Self {
    OSLogType.debug
  }
  
  /// A `fault` OSLogType level.
  public static var fault: Self {
    OSLogType.fault
  }
  
  /// An `error` OSLogType level.
  public static var error: Self {
    OSLogType.error
  }
  
  /// An `info` OSLogType level.
  public static var info: Self {
    OSLogType.info
  }
}
