import Foundation
import Loggable
import OSLog
import SwiftUI

struct Foo {
  @Omit(.parameters)
  @Tag(.debug)
  @Log(using: .signposter, omit: .result, tag: .debug)
  static func foo(value: String, int: Int) -> Bool {
    print("foo of intValue: \(value)")
    return true
  }

//  @Omit
//  static func someView() -> some View {
//    return EmptyView()
//  }
}

var voo = true
Foo.foo(value: "Gello", int: .zero)

