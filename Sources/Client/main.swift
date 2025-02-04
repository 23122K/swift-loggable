import Foundation
import Loggable
import OSLog

@Logged
class Foo {
  struct Person {
    var age = 12
  }
  
  static func bar(value: Int) -> Int {
    return value * 2
  }

  func someThrowingFunc() throws {
    throw NSError(domain: "foo.domain.com", code: 1)
  }
}

let foo = Foo()
do {
  try foo.someThrowingFunc()
} catch { }

Foo.bar(value: 1)
