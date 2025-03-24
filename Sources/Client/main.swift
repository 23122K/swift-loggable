import Foundation
import Loggable
import OSLog

@Log(using: .signposter)
func foo(value: String, int: Int) {
  print("foo of intValue: \(value)")
}

var voo = true
foo(value: "Gello", int: .zero)
