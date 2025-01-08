import Loggable
import OSLog

@available(macOS 11.0, *)
class Foo {
  static let logger = Logger(
    subsystem: "LoggablePlugin",
    category: "Log"
  )
  
  @Log
  func bar(value: String, line number: Int) -> Int {
    return number + 1
  }
  
  init() {
    print("Initialised")
  }
}

if #available(macOS 11, *) {
  let foo = Foo()
  print(foo.bar(value: "FoobarisWorking", line: 2))
}
