import Foundation
import Loggable
import OSLog
import SwiftUI

@OSLogged
struct Foo {
  @Omit(.result)
  static func foo(value: String, int: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }
}


//@OSLogged
extension Foo {
//  @OSLog(level: .error, tag: "OSLOgged tag", "other")
  static func bat() -> Int {
    return .zero
  }
}

var voo = true
Foo.foo(value: "Gello", int: .zero)
Foo.bat()


