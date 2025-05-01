import Foundation
import Loggable
import OSLog
import SwiftUI

@OSLogged
struct Foo {
  @Omit("result")
  static func foo(value: String, result: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }
}


extension Foo {
//  @OSLog(level: .error, tag: "OSLOgged tag", "other")
  static func bat() -> Int {
    return .zero
  }
}

var voo = true
Foo.foo(value: "Gello", result: .zero)
Foo.bat()


