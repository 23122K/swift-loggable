import LoggableCore

public enum __AccessLevel: Taggable {
  case tag(StringLiteralType)
  
  public init(stringLiteral value: StringLiteralType) {
    self = __AccessLevel.tag(value)
  }
}

extension Taggable where Self == __AccessLevel {
  public static var `public`: __AccessLevel {
    __AccessLevel(stringLiteral: "public")
  }
  
  public static var `internal`: __AccessLevel {
    __AccessLevel(stringLiteral: "internal")
  }
  
  public static var `fileprivate`: __AccessLevel {
    __AccessLevel(stringLiteral: "fileprivate")
  }
  
  public static var `private`: __AccessLevel {
    __AccessLevel(stringLiteral: "private")
  }
}
