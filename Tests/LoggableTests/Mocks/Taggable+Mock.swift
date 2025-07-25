import Loggable

enum MockTag: Taggable {
  case tag(String)
  
  init(stringLiteral value: StringLiteralType) {
    self = .tag(value)
  }
}

extension Taggable where Self == MockTag {
  static var mock: any Taggable {
    MockTag.tag("mock")
  }
}
