import Foundation
import Loggable
import OSLog
import SwiftUI

@Logged
struct Foo {
  @Tag(.info)
  @Omit(.result)
  static func foo(value: String, int: Int) {
    print("foo of intValue: \(value)")
  }

//  @Omit
  static func someView() -> some View {
    return EmptyView()
  }
}

var voo = true
Foo.foo(value: "Gello", int: .zero)

