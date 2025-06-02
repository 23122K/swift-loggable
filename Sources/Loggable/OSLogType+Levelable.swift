#if canImport(OSLog)
import struct OSLog.OSLogType
#endif

extension OSLogType: @retroactive ExpressibleByStringLiteral {}
extension OSLogType: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension OSLogType: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension OSLogType: @retroactive @unchecked Sendable {}
extension OSLogType: @retroactive Hashable {}
extension OSLogType: Levelable {
  public static func level(_ value: UInt8) -> OSLogType {
    OSLogType(value)
  }

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
  public static var `default`: Self {
    OSLogType.default
  }
  
  public static var debug: Self {
    OSLogType.debug
  }
  
  public static var fault: Self {
    OSLogType.fault
  }
  
  public static var error: Self {
    OSLogType.error
  }
  
  public static var info: Self {
    OSLogType.info
  }
}
