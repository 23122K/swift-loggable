import Foundation
import Loggable
import OSLog
import SwiftUI

@OSLogged
struct Foo {
//  @Omit(.result, .parameters)
//  @Tag(.error)
//  @Log(using: .signposter)
  static func foo(value: String, int: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }
}

extension Foo {
//  @OSLog(level: .error)
  static func bat() -> Int {
    return .zero
  }
}

var voo = true
Foo.foo(value: "Gello", int: .zero)
Foo.bat()


