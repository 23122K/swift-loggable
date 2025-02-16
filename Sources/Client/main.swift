import Foundation
import Loggable

@Log
func foo(
  value: String,
  _ intValue: Int = 0,
  someInout: inout Bool,
  callback: @escaping @autoclosure () throws -> String
) {
  print(try? callback())
  print("foo of intValue: \(value)")
}


var voo = true
foo(value: "Gello", someInout: &voo, callback: "Some callback")
