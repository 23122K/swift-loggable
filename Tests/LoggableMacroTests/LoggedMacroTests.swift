import LoggableMacro
import MacroTesting
import XCTest

final class LoggedMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      record: .never,
      macros: ["Logged": LoggedMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func test_class_withNoMacroDeclarations() throws {
    assertMacro {
      #"""
      @Logged
      class Foo {
        func identity<T>(_ value: T) -> T {
          return value
        }

        func makeIncrementer() -> (Int) -> Int {
          return { $0 + 1 }
        }

        func fetchData(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """#
    } expansion: {
      """
      class Foo {
        @Log
        func identity<T>(_ value: T) -> T {
          return value
        }
        @Log

        func makeIncrementer() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @Log

        func fetchData(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_class_withLogAndOmitMacroDeclarations() throws {
    assertMacro {
      #"""
      @Logged
      class Foo {
        func identity<T>(_ value: T) -> T {
          return value
        }

        @Omit
        func makeIncrementer() -> (Int) -> Int {
          return { $0 + 1 }
        }

        @Log
        func fetchData(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """#
    } expansion: {
      """
      class Foo {
        @Log
        func identity<T>(_ value: T) -> T {
          return value
        }

        @Omit
        func makeIncrementer() -> (Int) -> Int {
          return { $0 + 1 }
        }

        @Log
        func fetchData(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }
}
