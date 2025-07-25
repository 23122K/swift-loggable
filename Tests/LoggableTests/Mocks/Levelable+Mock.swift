import Loggable

enum MockLevel: String {
  case none
  case debug
  case error
}

extension MockLevel: Levelable {
  static func level(_ value: String) -> MockLevel {
    switch value {
      case "debug":
        return MockLevel.debug
        
      case "error":
        return MockLevel.error
        
      default:
        return MockLevel.none
    }
  }
  
  init(stringLiteral value: StringLiteralType) {
    switch value {
      case "debug":
        self = MockLevel.debug
        
      case "error":
        self = MockLevel.error
        
      default:
        self = MockLevel.none
    }
  }
}

extension Levelable where Self == MockLevel {
  static var mockNone: any Levelable {
    MockLevel.none
  }
  
  static var mockDebug: any Levelable {
    MockLevel.debug
  }
  
  static var mockError: any Levelable {
    MockLevel.error
  }
}
