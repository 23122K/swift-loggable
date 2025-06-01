import Loggable


extension TaggableTrait {
  static let foo = Self.tag("my private tag")
}

extension Taggable where Self == TaggableTrait {
  static var foo: Self {
    TaggableTrait.foo
  }
}

let tags: [any Taggable] = [
  "WIP",
  .foo,
  TaggableTrait.tag("shit")
]

@Logged
struct Foo {
//  @Level(.debug)
  @Tag("bar", .foo)
  @Log(level: .debug, omit: .parameters, .result, "qux")
  static func foo(value: String) -> Void {
    print("Executed \(value)")
  }
}

Foo.foo(value: "test")
