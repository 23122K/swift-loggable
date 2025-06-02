import Loggable

enum Tags: Taggable {
  case tag(String)
  
  init(stringLiteral value: StringLiteralType) {
    self = .tag(value)
  }
}

extension Taggable where Self == Tags {
  static var foo: Self {
    self.tag("frajer")
  }
}


let tags: [any Taggable] = [
  "WIP",
  .foo,
  Tags.tag("shit")
]

@Logged
struct Foo {
  @Tag("bar", .foo)
  @Omit(.parameters)
  @Level(.error)
  static func foo(value: String) -> String {
    print("Executed \(value)")
    return value
  }
}

Foo.foo(value: "test")
