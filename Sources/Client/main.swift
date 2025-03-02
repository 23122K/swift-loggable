import Foundation
import Loggable

@Log
func foo(value: String) {
  print("foo of intValue: \(value)")
}

var voo = true
foo(value: "Gello")
