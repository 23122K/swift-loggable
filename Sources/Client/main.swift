import Loggable

public struct Printer: Loggable {
  public func emit(event: LoggableEvent) {
    print("event")
  }
  
  public init() {
    
  }
}

extension Loggable where Self == Printer {
  public static var printer: any Loggable {
    Printer()
  }
}

@Logged(using: .printer)
struct Foo {
  func bar() {
    print("1")
  }
  
  func baz() {
    print("2")
  }
}

let foo = Foo()
foo.bar()
foo.baz()
