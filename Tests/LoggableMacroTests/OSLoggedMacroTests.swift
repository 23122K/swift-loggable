import LoggableMacro
import MacroTesting
import XCTest

final class OSLoggedMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      indentationWidth: .spaces(2),
      record: .missing,
      macros: ["OSLogged": OSLoggedMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func test_struct_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLogged
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
        @OSLog
        func bar<T>(_ value: T) -> T {
          return value
        }
        @OSLog

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @OSLog

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }

        static let logger = Logger(subsystem: "Foo", category: "Foo")
      }
      """
    }
  }

  func test_class_withCustomSubsystemAndCategory_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLogged(subsystem: "OSLoggedMacroTests", category: "class")
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
        @OSLog
        func bar<T>(_ value: T) -> T {
          return value
        }
        @OSLog

        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }
        @OSLog

        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }

        static let logger = Logger(subsystem: "OSLoggedMacroTests", category: "class")
      }
      """
    }
  }

  func test_actor_default_withOmmitAnnotations() throws {
    assertMacro {
      #"""
      @OSLogged
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
        @OSLog
        func bar<T>(_ value: T) -> T {
          return value
        }

        @Omit
        func quaz() -> (Int) -> Int {
          return { $0 + 1 }
        }

        @Omit(.result)
        @OSLog
        static func quuaz(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }

        static let logger = Logger(subsystem: "Foo", category: "Foo")
      }
      """
    }
  }

  func test_enum_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLogged
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
        @OSLog

        static func _bar() -> Foo { 
          Foo.bar(.example)
        }

        static let logger = Logger(subsystem: "Foo", category: "Foo")
      }
      """
    }
  }

  func test_extension_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLogged
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
        @OSLog
        mutating func bar() -> Self {
          self.bar = .example
          return self
        }
        @OSLog

        static func quaz(quuaz: Quuaz) -> Self { 
          Self(bar: nil, quuaz: quaaz)
        }

        static let logger = Logger(subsystem: "Foo ", category: "Foo ")
      }
      """
    }
  }
}
