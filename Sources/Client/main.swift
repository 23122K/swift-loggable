import Foundation
import Loggable
import OSLog
import SwiftUI

// Logged
// Log
// Omit
// Tag

// OSLogged
// OSLog(level:, message:)

@Logged
struct Foo {
//  static let logger = Logger(subsystem: "Xcode", category: "x")
//  @Omit(.parameters)
//  @Tag(.debug)
//  @Tag(.error)
//  @OSLog(level: .fault)
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


