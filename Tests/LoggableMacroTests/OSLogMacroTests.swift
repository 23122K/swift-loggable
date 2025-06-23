import LoggableMacro
import MacroTesting
import Testing

@Suite(
  .macros(
    [OSLogMacro.self],
    indentationWidth: .spaces(2),
    record: .missing
  )
)
struct OSLogMacroTests {
  @Test
  func function_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLog
      func foo() { 
        print("Foo")
      }
      """#
    } expansion: {
      """
      func foo() {
        let loggable: any Loggable = Self.logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo()",
          parameters: [:],
          tags: []
        )
        print("Foo")
        loggable.emit(event: event)
      }
      """
    }
  }

  @Test
  func intFunctionWithVariadicParameters_taggableAsStringLiteralType_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLog(tag: "example")
      func sum(numbers: Int...) -> Int {
        return numbers.reduce(0, +)
      }
      """#
    } expansion: {
      """
      func sum(numbers: Int...) -> Int {
        let loggable: any Loggable = Self.logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func sum(numbers: Int...) -> Int",
          parameters: [
            "numbers": numbers
          ],
          tags: ["example"]
        )
        func _sum(numbers: Int...) -> Int {
          return numbers.reduce(0, +)
        }
        let result = _sum(numbers: numbers)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  @Test
  func functionWithArguments_allTraits_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @OSLog(level: .debug, omit: .result, .parameters, tag: .commonTag, "example")
      func transform(value: Int, using transform: (Int) -> String) -> String {
        return transform(value)
      }
      """#
    } expansion: {
      """
      func transform(value: Int, using transform: (Int) -> String) -> String {
        let loggable: any Loggable = Self.logger
        let event = LoggableEvent(
          level: .debug,
          location: "TestModule/Test.swift:1:1",
          declaration: "func transform(value: Int, using transform: (Int) -> String) -> String",
          tags: [.commonTag, "example"]
        )
        func _transform(value: Int, transform: (Int) -> String) -> String {
          return transform(value)
        }
        let result = _transform(value: value, transform: transform)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

// TODO: 23122K - Multiple @Tag macros have non-deterministic order
//  func test_genericFunction_default_withAllAnnotations() throws {
//    assertMacro {
//      #"""
//      @Omit(.result, "value")
//      @Tag("example")
//      @Tag(.commonTag)
//      @Level(.info)
//      @OSLog
//      func identity<T>(_ value: T) -> T {
//        return value
//      }
//      """#
//    } expansion: {
//      """
//      @Omit(.result, "value")
//      @Tag("example")
//      @Tag(.commonTag)
//      @Level(.info)
//      func identity<T>(_ value: T) -> T {
//        let loggable: any Loggable = Self.logger
//        var event = LoggableEvent(
//          level: "level_info",
//          location: "TestModule/Test.swift:5:1",
//          declaration: "func identity<T>(_ value: T) -> T",
//          tags: ["tag_example", "tag_commonTag"]
//        )
//        event.parameters = [
//          :
//        ]
//        func _identity(value: T) -> T {
//          return value
//        }
//        let result = _identity(value: value)
//        loggable.emit(event: event)
//        return result
//      }
//      """
//    }
//  }
}
