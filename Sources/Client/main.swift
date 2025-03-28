import Foundation
import Loggable
import OSLog
import SwiftUI

extension Ommitable where Self == Loggable.Trait {
  static var int: Self { ._parameter("int") }
}

@Redact(.result)
@Log
func foo(value: String, int: Int) {
  print("foo of intValue: \(value)")
}

var voo = true
foo(value: "Gello", int: .zero)
