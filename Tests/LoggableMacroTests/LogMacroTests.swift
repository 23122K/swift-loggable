import LoggableMacro
import MacroTesting
import XCTest

final class LogMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      indentationWidth: .spaces(2),
      record: .missing,
      macros: [LogMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func test_voidFunction_default_noAdditinalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func foo() { 
        print("Foo")
      }
      """#
    } expansion: {
      """
      func foo() {
        let loggable: any Loggable = .logger
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

  func test_voidFunction_lggableAsInitializer_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log(using: CustomLogger())
      func foo() { 
        print("Foo")
      }
      """#
    } expansion: {
      """
      func foo() {
        let loggable: any Loggable = CustomLogger()
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

  func test_voidFunction_loggableAsStaticParameter_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log(using: .custom)
      func foo() { 
        print("Foo")
      }
      """#
    } expansion: {
      """
      func foo() {
        let loggable: any Loggable = .custom
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

  func test_stringFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func foo() -> String { 
        return "Foo"
      }
      """#
    } expansion: {
      """
      func foo() -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() -> String",
          parameters: [:],
          tags: []
        )
        func _foo() -> String {
          return "Foo"
        }
        let result = _foo()
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func
    test_stringFunctionWithArguments_loggableAndLevelableAsStaticParameters_noAdditionalAnnotations()
    throws
  {
    assertMacro {
      #"""
      @Log(using: .foo, level: .debug)
      func foo(bar: String) -> String { 
        print("Foo: \(bar)")
      }
      """#
    } expansion: {
      #"""
      func foo(bar: String) -> String {
        let loggable: any Loggable = .foo
        var event = LoggableEvent(
          level: .debug,
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(bar: String) -> String",
          parameters: [
            "bar": bar
          ],
          tags: []
        )
        func _foo(bar: String) -> String {
          print("Foo: \(bar)")
        }
        let result = _foo(bar: bar)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_stringFunctionWithArgument_taggableAsStringLiteralType_noAdditionalAnnotations() throws
  {
    assertMacro {
      #"""
      @Log(tag: "example")
      func foo(bar: String) -> String { 
        return "Foo: \(bar)"
      }
      """#
    } expansion: {
      #"""
      func foo(bar: String) -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(bar: String) -> String",
          parameters: [
            "bar": bar
          ],
          tags: ["example"]
        )
        func _foo(bar: String) -> String {
          return "Foo: \(bar)"
        }
        let result = _foo(bar: bar)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_tupleFunctionWithLabeledArguments_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func foo(_ bar: String, baz biz: Int) -> (String, Int) { 
        return ("Bar: \(bar)", biz * 2) 
      }
      """#
    } expansion: {
      #"""
      func foo(_ bar: String, baz biz: Int) -> (String, Int) {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ bar: String, baz biz: Int) -> (String, Int)",
          parameters: [
            "bar": bar,
            "biz": biz
          ],
          tags: []
        )
        func _foo(bar: String, biz: Int) -> (String, Int) {
          return ("Bar: \(bar)", biz * 2)
        }
        let result = _foo(bar: bar, biz: biz)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_mutatingFunction_default_withLevelAnnotation() throws {
    assertMacro {
      #"""
      @Level(.debug)
      @Log
      mutating func foo() { 
        self.counter += 1 
      }
      """#
    } expansion: {
      """
      @Level(.debug)
      mutating func foo() {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          level: .debug,
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo()",
          parameters: [:],
          tags: []
        )
        self.counter += 1
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_mutatingFunctionWithArgument_taggableAndLevelableAsPrameters_noAdditionalAnnotations()
    throws
  {
    assertMacro {
      #"""
      @Log(level: .debug, tag: .common, "example")
      mutating func foo(bar: String) { 
        self.bar = bar
      }
      """#
    } expansion: {
      """
      mutating func foo(bar: String) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          level: .debug,
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo(bar: String)",
          parameters: [
            "bar": bar
          ],
          tags: [.common, "example"]
        )
        self.bar = bar
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_mutatingThrowingFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      mutating func foo() throws {
        if self.counter == 0 {
          throw NSError(domain: com.foo.test, code: .zero)
        } else {
          self.counter -= 1
        }
      }
      """#
    } expansion: {
      """
      mutating func foo() throws {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo() throws",
          parameters: [:],
          tags: []
        )
        func _foo() throws {
          if self.counter == 0 {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            self.counter -= 1
          }
        }
        do {
          let _ = try _foo()
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_default_withTagAndLevelAnnotations() throws {
    assertMacro {
      #"""
      @Level(.error)
      @Tag("example")
      @Log
      func foo() throws {
        throw NSError()
      }
      """#
    } expansion: {
      """
      @Level(.error)
      @Tag("example")
      func foo() throws {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          level: .error,
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() throws",
          parameters: [:],
          tags: ["example"]
        )
        func _foo() throws {
          throw NSError()
        }
        do {
          let _ = try _foo()
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func foo() throws -> Int {
        if Bool.random() {
          throw NSError(domain: com.foo.test, code: .zero)
        } else {
          return .zero
        }
      }
      """#
    } expansion: {
      """
      func foo() throws -> Int {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() throws -> Int",
          parameters: [:],
          tags: []
        )
        func _foo() throws -> Int {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return .zero
          }
        }
        do {
          let result = try _foo()
          event.result = .success(result)
          loggable.emit(event: event)
          return result
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunctionWithArgument_default_withOmitParameterAnnotation() throws {
    assertMacro {
      #"""
      @Omit("value")
      @Log
      func foo(_ value: Int) throws {
        if Bool.random() {
          print("true")
          throw NSError(domain: com.foo.test, code: .zero)
        } else {
          print("false")
        }
      }
      """#
    } expansion: {
      """
      @Omit("value")
      func foo(_ value: Int) throws {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ value: Int) throws",
          parameters: [
            "value": value
          ],
          tags: []
        )
        func _foo(value: Int) throws {
          if Bool.random() {
            print("true")
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            print("false")
          }
        }
        do {
          let _ = try _foo(value: value)
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunctionWithArguments_omittableAsStaticParameter_noAdditionalAnnotations()
    throws
  {
    assertMacro {
      #"""
      @Log(omit: .parameters)
      func foo(_ value: Int, content: String) throws -> (Int, String) {
        if Bool.random() {
          throw NSError(domain: com.foo.test, code: .zero)
        } else {
          return (value, "\(content): \(value)")
        }
      }
      """#
    } expansion: {
      #"""
      func foo(_ value: Int, content: String) throws -> (Int, String) {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ value: Int, content: String) throws -> (Int, String)",
          tags: []
        )
        func _foo(value: Int, content: String) throws -> (Int, String) {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return (value, "\(content): \(value)")
          }
        }
        do {
          let result = try _foo(value: value, content: content)
          event.result = .success(result)
          loggable.emit(event: event)
          return result
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """#
    }
  }

  func test_asyncThrowingFunction_levelableAsStringLiteralTypeParameter_withTagAnnotation() throws {
    assertMacro {
      #"""
      @Tag("example")
      @Log(level: "fault")
      func foo() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
      }
      """#
    } expansion: {
      """
      @Tag("example")
      func foo() async throws {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          level: "fault",
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() async throws",
          parameters: [:],
          tags: ["example"]
        )
        func _foo() async throws {
          try await Task.sleep(nanoseconds: 100_000_000)
        }
        do {
          let _ = try await _foo()
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_functionWithEscapingClosure_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func performTask(completion: @escaping () -> Void) {
        completion()
      }
      """#
    } expansion: {
      """
      func performTask(completion: @escaping () -> Void) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performTask(completion: @escaping () -> Void)",
          parameters: [
            "completion": completion
          ],
          tags: []
        )
        completion()
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_functionWithAutoclosureArgument_omittableAsStaticParameter_withLevelAnnotation() throws
  {
    assertMacro {
      #"""
      @Level(.info)
      @Log(omit: .result)
      func check(condition: @autoclosure () -> Bool) -> Bool {
        return condition()
      }
      """#
    } expansion: {
      """
      @Level(.info)
      func check(condition: @autoclosure () -> Bool) -> Bool {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          level: .info,
          location: "TestModule/Test.swift:1:1",
          declaration: "func check(condition: @autoclosure () -> Bool) -> Bool",
          parameters: [
            "condition": condition
          ],
          tags: []
        )
        func _check(condition: @autoclosure () -> Bool) -> Bool {
          return condition()
        }
        let result = _check(condition: condition())
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_functionWithInoutArgument_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func update(value: inout Int, with newValue: Int) {
        value = newValue
      }
      """#
    } expansion: {
      """
      func update(value: inout Int, with newValue: Int) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func update(value: inout Int, with newValue: Int)",
          parameters: [
            "value": value,
            "newValue": newValue
          ],
          tags: []
        )
        value = newValue
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_staticFunctionWithArgument_omittableAsStringLiteralType_withOmitResultAnnotation()
    throws
  {
    assertMacro {
      #"""
      @Omit(.result)
      @Log(omit: "info")
      static func staticMethod(info: String) -> String {
        return "Static: \(info)"
      }
      """#
    } expansion: {
      #"""
      @Omit(.result)
      static func staticMethod(info: String) -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "static func staticMethod(info: String) -> String",
          parameters: [
            "info": info
          ],
          tags: []
        )
        func _staticMethod(info: String) -> String {
          return "Static: \(info)"
        }
        let result = _staticMethod(info: info)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func
    test_rethrowsFunctionWithClosureArgument_omittableAsStringLiteralType_withRedundatOmitParameterAnnotation()
    throws
  {
    assertMacro {
      #"""
      @Omit("operation")
      @Log(omit: "operation")
      func execute(operation: () throws -> Void) rethrows {
        try operation()
      }
      """#
    } expansion: {
      """
      @Omit("operation")
      func execute(operation: () throws -> Void) rethrows {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func execute(operation: () throws -> Void) rethrows",
          parameters: [
            "operation": operation
          ],
          tags: []
        )
        func _execute(operation: () throws -> Void) rethrows {
          try operation()
        }
        do {
          let _ = try _execute(operation: operation)
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_functionWithArguments_allTraits_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log(using: .custom, level: .debug, omit: .result, .parameters, tag: .commonTag, "example")
      func transform(value: Int, using transform: (Int) -> String) -> String {
        return transform(value)
      }
      """#
    } expansion: {
      """
      func transform(value: Int, using transform: (Int) -> String) -> String {
        let loggable: any Loggable = .custom
        var event = LoggableEvent(
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
//      @Log
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
//        let loggable: any Loggable = .logger
//        var event = LoggableEvent(
//          level: "level_info",
//          location: "TestModule/Test.swift:5:1",
//          declaration: "func identity<T>(_ value: T) -> T",
//          tags: ["tag_commonTag", "tag_example"]
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

  func test_genericTupleFunctionWithWhereClauseAndArguments_default_withRedundantTagAnnotation()
    throws
  {
    assertMacro {
      #"""
      @Tag(.example, "example")
      @Log
      func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible {
        return (first, second)
      }
      """#
    } expansion: {
      """
      @Tag(.example, "example")
      func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible",
          parameters: [
            "first": first,
            "second": second
          ],
          tags: [.example, "example"]
        )
        func _combine(first: T, second: U) -> (T, U) {
          return (first, second)
        }
        let result = _combine(first: first, second: second)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_stringFunctionWithDefaultParameters_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func greet(name: String = "Guest") -> String {
        return "Hello, \(name)!"
      }
      """#
    } expansion: {
      #"""
      func greet(name: String = "Guest") -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: #"func greet(name: String = "Guest") -> String"#,
          parameters: [
            "name": name
          ],
          tags: []
        )
        func _greet(name: String) -> String {
          return "Hello, \(name)!"
        }
        let result = _greet(name: name)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_intFunctionWithVariadicParameters_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func sum(numbers: Int...) -> Int {
        return numbers.reduce(0, +)
      }
      """#
    } expansion: {
      """
      func sum(numbers: Int...) -> Int {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func sum(numbers: Int...) -> Int",
          parameters: [
            "numbers": numbers
          ],
          tags: []
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

  func test_functionWithArgument_default_withDiscardableResultAndOmitResultAnnotations() throws {
    assertMacro {
      #"""
      @Omit(.result)
      @Log
      @discardableResult
      func compute(value: Int) -> Int {
        return value * value
      }
      """#
    } expansion: {
      """
      @Omit(.result)
      @discardableResult
      func compute(value: Int) -> Int {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func compute(value: Int) -> Int",
          parameters: [
            "value": value
          ],
          tags: []
        )
        func _compute(value: Int) -> Int {
          return value * value
        }
        let result = _compute(value: value)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_intClosureFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func makeIncrementer() -> (Int) -> Int {
        return { $0 + 1 }
      }
      """#
    } expansion: {
      """
      func makeIncrementer() -> (Int) -> Int {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func makeIncrementer() -> (Int) -> Int",
          parameters: [:],
          tags: []
        )
        func _makeIncrementer() -> (Int) -> Int {
          return {
            $0 + 1
          }
        }
        let result = _makeIncrementer()
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_functionWithAsyncClosureArgument_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func fetchData(completion: @escaping () async -> String) {
        Task {
          let data = await completion()
          print(data)
        }
      }
      """#
    } expansion: {
      """
      func fetchData(completion: @escaping () async -> String) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func fetchData(completion: @escaping () async -> String)",
          parameters: [
            "completion": completion
          ],
          tags: []
        )
        Task {
            let data = await completion()
            print(data)
          }
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_functionWithArgument_default_mainActorAnnotation() throws {
    assertMacro {
      #"""
      @Log
      @MainActor
      func updateUI(message: String) {
        print(message)
      }
      """#
    } expansion: {
      """
      @MainActor
      func updateUI(message: String) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func updateUI(message: String)",
          parameters: [
            "message": message
          ],
          tags: []
        )
        print(message)
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_genericFunctionWithMultipleConstraints_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool {
        return true
      }
      """#
    } expansion: {
      """
      func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool",
          parameters: [
            "first": first,
            "second": second
          ],
          tags: []
        )
        func _process(first: T, second: U) -> Bool {
          return true
        }
        let result = _process(first: first, second: second)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_default_objcAnnotation() throws {
    assertMacro {
      #"""
      @Log
      @objc
      func performAction() {
        print("Action performed")
      }
      """#
    } expansion: {
      """
      @objc
      func performAction() {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performAction()",
          parameters: [:],
          tags: []
        )
        print("Action performed")
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_optionalIntFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func getOptionalValue() -> Int? {
        return nil
      }
      """#
    } expansion: {
      """
      func getOptionalValue() -> Int? {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func getOptionalValue() -> Int?",
          parameters: [:],
          tags: []
        )
        func _getOptionalValue() -> Int? {
          return nil
        }
        let result = _getOptionalValue()
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_stringFunctionWithAsyncThrowingClosureParameter_default_noAdditionalAnnotations() throws
  {
    assertMacro {
      #"""
      @Log
      func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String {
        return try await completion()
      }
      """#
    } expansion: {
      """
      func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String",
          parameters: [
            "completion": completion
          ],
          tags: []
        )
        func _performAsyncTask(completion: @escaping () async throws -> String) async throws -> String {
          return try await completion()
        }
        do {
          let result = try await _performAsyncTask(completion: completion)
          event.result = .success(result)
          loggable.emit(event: event)
          return result
        } catch {
          event.result = .failure(error)
          loggable.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_overridingStringFunction_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      override func description() -> String {
        return "Override"
      }
      """#
    } expansion: {
      """
      override func description() -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "override func description() -> String",
          parameters: [:],
          tags: []
        )
        func _description() -> String {
          return "Override"
        }
        let result = _description()
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_functionWithInoutAndDefaultArgument_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func updateScore(score: inout Int, increment: Int = 1) {
        score += increment
      }
      """#
    } expansion: {
      """
      func updateScore(score: inout Int, increment: Int = 1) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func updateScore(score: inout Int, increment: Int = 1)",
          parameters: [
            "score": score,
            "increment": increment
          ],
          tags: []
        )
        score += increment
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_functionWithOptionalArgument_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func optionalTest(value: String?) -> String {
        return value ?? "Default"
      }
      """#
    } expansion: {
      """
      func optionalTest(value: String?) -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func optionalTest(value: String?) -> String",
          parameters: [
            "value": value
          ],
          tags: []
        )
        func _optionalTest(value: String?) -> String {
          return value ?? "Default"
        }
        let result = _optionalTest(value: value)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_genericFunctionWithComplexSignature_default_withOmitSecondParameterAnnotation() throws {
    assertMacro {
      #"""
      @Omit("second")
      @Log
      func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]
        where T: Comparable, U: Comparable
      {
        return []
      }
      """#
    } expansion: {
      #"""
      @Omit("second")
      func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]
        where T: Comparable, U: Comparable{
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]\n  where T: Comparable, U: Comparable",
          parameters: [
            "first": first,
            "second": second
          ],
          tags: []
        )
        func _merge(first: [T], second: [U]) -> [(T, U)]
        {
          return []
        }
        let result = _merge(first: first, second: second)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_functionWithClosureDefaultValue_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func perform(action: (() -> Void)? = nil) {
        action?()
      }
      """#
    } expansion: {
      """
      func perform(action: (() -> Void)? = nil) {
        let loggable: any Loggable = .logger
        let event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func perform(action: (() -> Void)? = nil)",
          parameters: [
            "action": action
          ],
          tags: []
        )
        action?()
        loggable.emit(event: event)
      }
      """
    }
  }

  func test_staticGenericFunction_default_withDiscardableResultAnnotation() throws {
    assertMacro {
      #"""
      @Log
      @discardableResult
      static func create<T>(value: T) -> [T] {
        return [value]
      }
      """#
    } expansion: {
      """
      @discardableResult
      static func create<T>(value: T) -> [T] {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "static func create<T>(value: T) -> [T]",
          parameters: [
            "value": value
          ],
          tags: []
        )
        func _create(value: T) -> [T] {
          return [value]
        }
        let result = _create(value: value)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_stringFunctionWithTupleParameter_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func process(pair: (Int, String)) -> String {
        return "\(pair.0) - \(pair.1)"
      }
      """#
    } expansion: {
      #"""
      func process(pair: (Int, String)) -> String {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func process(pair: (Int, String)) -> String",
          parameters: [
            "pair": pair
          ],
          tags: []
        )
        func _process(pair: (Int, String)) -> String {
          return "\(pair.0) - \(pair.1)"
        }
        let result = _process(pair: pair)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_genericFunctionWithGenericClosureParameter_default_noAdditionalAnnotations() throws {
    assertMacro {
      #"""
      @Log
      func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T] {
        return elements.filter(predicate)
      }
      """#
    } expansion: {
      """
      func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T] {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T]",
          parameters: [
            "elements": elements,
            "predicate": predicate
          ],
          tags: []
        )
        func _filterElements(elements: [T], predicate: (T) -> Bool) -> [T] {
          return elements.filter(predicate)
        }
        let result = _filterElements(elements: elements, predicate: predicate)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }

  func test_genericArrayfunctionWithGenericClosureArgument_default_noAdditionalAnnotations() throws
  {
    assertMacro {
      #"""
      @Log
      func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T] {
        return elements.filter(predicate)
      }
      """#
    } expansion: {
      """
      func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T] {
        let loggable: any Loggable = .logger
        var event = LoggableEvent(
          location: "TestModule/Test.swift:1:1",
          declaration: "func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T]",
          parameters: [
            "elements": elements,
            "predicate": predicate
          ],
          tags: []
        )
        func _filterElements(elements: [T], predicate: (T) -> Bool) -> [T] {
          return elements.filter(predicate)
        }
        let result = _filterElements(elements: elements, predicate: predicate)
        event.result = .success(result)
        loggable.emit(event: event)
        return result
      }
      """
    }
  }
}
