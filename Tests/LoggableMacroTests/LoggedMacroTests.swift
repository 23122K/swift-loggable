import LoggableMacro
import MacroTesting
import XCTest

final class LoggedMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      indentationWidth: .spaces(2),
      record: .missing,
      macros: ["Logged": LoggedMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func test_struct_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged
      struct Foo {
        func bar<T>(_ value: T) -> T {
          return value
        }

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """#
    } expansion: {
      """
      struct Foo {
        @Log
        func bar<T>(_ value: T) -> T {
          return value
        }
        @Log

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @Log

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_class_withLoggableAsStaticParameter_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged(using: .custom)
      class Foo {
        func bar<T>(_ value: T) -> T {
          return value
        }

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        static func quuaz(completion: @escaping () async -> String) {
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
        @Log(using: .custom)
        func bar<T>(_ value: T) -> T {
          return value
        }
        @Log(using: .custom)

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @Log(using: .custom)

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_class_withLoggableAsInitializer_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged(using: Custom())
      class Foo {
        func bar<T>(_ value: T) -> T {
          return value
        }

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        static func quuaz(completion: @escaping () async -> String) {
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
        @Log(using: Custom())
        func bar<T>(_ value: T) -> T {
          return value
        }
        @Log(using: Custom())

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @Log(using: Custom())

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_class_withLoggableAsFunction_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged(using: .custom(module: "Foo"))
      class Foo {
        func bar<T>(_ value: T) -> T {
          return value
        }

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        static func quuaz(completion: @escaping () async -> String) {
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
        @Log(using: .custom(module: "Foo"))
        func bar<T>(_ value: T) -> T {
          return value
        }
        @Log(using: .custom(module: "Foo"))

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @Log(using: .custom(module: "Foo"))

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_actor_default_withOmmitAnnotations() throws {
    assertMacro {
      #"""
      @Logged
      actor Foo {
        @Omit(.parameters)
        func bar<T>(_ value: T) -> T {
          return value
        }

        @Omit
        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        @Omit(.result)
        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """#
    } expansion: {
      """
      actor Foo {
        @Omit(.parameters)
        @Log
        func bar<T>(_ value: T) -> T {
          return value
        }

        @Omit
        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        @Omit(.result)
        @Log
        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
      }
      """
    }
  }

  func test_enum_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged
      enum Foo {
        case bar(Bar)
        case quaz
        case quuaz

        static func _bar() -> Foo { 
          Foo.bar(.example)
        }
      }
      """#
    } expansion: {
      """
      enum Foo {
        case bar(Bar)
        case quaz
        case quuaz
        @Log

        static func _bar() -> Foo { 
          Foo.bar(.example)
        }
      }
      """
    }
  }

  func test_extension_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Logged
      extension Foo {
        mutating func bar() -> Self {
          self.bar = .example
          return self
        }

        static func quaz(quuaz: Quuaz) -> Self { 
          Self(bar: nil, quuaz: quaaz)
        }
      }
      """#
    } expansion: {
      """
      extension Foo {
        @Log
        mutating func bar() -> Self {
          self.bar = .example
          return self
        }
        @Log

        static func quaz(quuaz: Quuaz) -> Self { 
          Self(bar: nil, quuaz: quaaz)
        }
      }
      """
    }
  }
}
