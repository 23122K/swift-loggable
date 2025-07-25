public import Sentry
public import Loggable

struct SentryLogger: Loggable {
  func emit(event: LoggableEvent) {
    switch event.result {
      case .success:
        SentrySDK.addBreadcrumb(event.sentryBreadcrumb)
        
      case let .failure(error):
        SentrySDK.capture(error: error) { scope in
          scope.setTags(event.sentryErrorTags)
        }
    }
  }
}

extension Loggable where Self == SentryLogger {
  static var sentry: any Loggable {
    SentryLogger()
  }
}

// TODO: 23122K - Can this be synthesized automatically through macros?
extension SentryLevel: @retroactive @unchecked Sendable {}
extension SentryLevel: @retroactive ExpressibleByStringLiteral {}
extension SentryLevel: @retroactive Levelable {
  public static func level(_ value: UInt) -> Self {
    SentryLevel(rawValue: value) ?? SentryLevel.none
  }
  
  public init(stringLiteral value: StringLiteralType) {
    switch value {
      case "none":
        self = SentryLevel.none
        
      case "debug":
        self = SentryLevel.debug
        
      case "info":
        self = SentryLevel.info
        
      case "warning":
        self = SentryLevel.warning
        
      case "error":
        self = SentryLevel.error
        
      case "fatal":
        self = SentryLevel.fatal
        
      default:
        self = SentryLevel.none
    }
  }
}

extension Levelable where Self == SentryLevel {
  static var sentryNone: any Levelable {
    SentryLevel.none
  }
  
  static var sentryDebug: any Levelable {
    SentryLevel.debug
  }
  
  static var sentryInfo: any Levelable {
    SentryLevel.info
  }
  
  static var sentryWarning: any Levelable {
    SentryLevel.warning
  }
  
  static var sentryError: any Levelable {
    SentryLevel.error
  }
  
  static var sentryFatal: any Levelable {
    SentryLevel.fatal
  }
}

extension LoggableEvent {
  var sentryBreadcrumb: Sentry.Breadcrumb {
    let breadcrumb = Sentry.Breadcrumb()
    if let level = self.level as? SentryLevel {
      breadcrumb.level = level
    }
    breadcrumb.category = "Action"
    breadcrumb.type = "user"
    breadcrumb.message = self.description
    return breadcrumb
  }
  
  var sentryErrorTags: [String: String] {
    [
      "error.function.signature": self.declaration,
      "error.function.parameters": self.parameters.mapValues { String(reflecting: $0) }.description,
      "error.function.location": self.location,
    ]
  }
}
