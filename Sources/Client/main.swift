import Loggable

@Logged
struct Foo {
  func bar() {
    print("1")
  }
  
  @Omit("value")
  func baz(value: String) {
    print("2")
  }
}

let foo = Foo()
foo.bar()
foo.baz(value: "foo")
