import Foundation
import Loggable
import OSLog
import SwiftUI

@OSLogger
@OSLogged
struct Foo {
  static func foo(value: String, result: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }
}

@OSLogged
extension Foo {
  static func bat() -> Int {
    return .zero
  }
}

var voo = true
Foo.foo(value: "Gello", result: .zero)
Foo.bat()
