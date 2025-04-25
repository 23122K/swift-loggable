import Foundation
import Loggable
import OSLog
import SwiftUI

struct NSLogger: Loggable {
  func emit(event: LoggableEvent) {
    NSLog("%@", event.description)
  }
}

extension Loggable where Self == NSLogger {
  static var nsLogger: Self { NSLogger() }
}

struct Foo {
  @Log(using: .nsLogger)
  static func foo(value: String, int: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }
}


@OSLogged
extension Foo {
//  @OSLog(level: .error, tag: "OSLOgged tag", "other")
  static func bat() -> Int {
    return .zero
  }
}

var voo = true
Foo.foo(value: "Gello", int: .zero)
Foo.bat()


