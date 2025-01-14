import Foundation
import Loggable
import OSLog

public final class Bar: Loggable, @unchecked Sendable {
  let logger = Logger(subsystem: "X", category: "X")
  override public func message(location: String) {
    logger.info("\(location)")
  }
  
  override public init() {
    super.init()
  }
}

extension Loggable {
  public static let bar: Loggable = {
    Bar()
  }()
}

let loggable = Loggable.bar
@Logged(using: loggable)
class Foo {
  func bar(value: Int) -> String {
    return String(value)
  }
  
  init() {
    print("initalised")
  }
}

let foo = Foo()
print(foo.bar(value: 2))
