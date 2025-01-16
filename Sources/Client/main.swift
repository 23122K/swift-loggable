import Foundation
import Loggable
import OSLog

public final class Bar: Loggable, @unchecked Sendable {
  let logger = Logger(subsystem: "X", category: "X")
  override public func message(location: String) {
    logger.info("\(location)")
  }
  
  public static func build() -> Bar {
    Bar()
  }
  
  override public init() {
    super.init()
  }
}

extension Loggable {
  public static func bar() -> Bar {
    Bar()
  }
}

@Logged
class Foo {
  static func bar(value: Int) -> String {
    return String(value)
  }
  
  init() {
    print("initalised")
  }
}
let foo = Foo()
print(Foo.bar(value: 2))
