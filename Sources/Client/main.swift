import Foundation
import Loggable
import OSLog
import LocalAuthentication

//@Logged
class Foo<E: Error> {
  struct Person {
    var age = 12
  }
  
  @Log
  func bar(_ value: @escaping @autoclosure () -> Int) -> Int {
    return value()
  }
  
  @Log
  func baz(value: inout Int) -> Int {
    return value * 2
  }
  
  func genericParameter(error: E) throws {
    throw error
  }
  
  func genericParameterWithWhereClouse(error: E) throws {
    throw error
  }
}

let foo = Foo<NSError>()
let x: () -> Int = { 2 }
var y = 2
foo.baz(value: &y)
foo.bar(1)
foo.bar(x())
foo.bar( { 3 }() )

