import LoggableMacro
import MacroTesting
import XCTest

final class LogMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      record: .never,
      macros: ["Log": LogMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func test_function_withNoParameters_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo()"
        )
        print("Foo")
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_function_withNoParameters_returnsVoid_customLogger() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo()"
        )
        print("Foo")
        CustomLogger().emit(event: event)
      }
      """
    }
  }

  func test_function_withNoParameters_returnsVoid_customStaticLogger() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo()"
        )
        print("Foo")
        Loggable.custom.emit(event: event)
      }
      """
    }
  }

  func test_function_withNoParameters_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() -> String"
        )
        func _foo() -> String {
          return "Foo"
        }
        let result = _foo()
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withParameters_returnsVoid() throws {
    assertMacro {
      #"""
      @Log
      func foo(bar: String) -> String { 
        print("Foo: \(bar)")
      }
      """#
    } expansion: {
      #"""
      func foo(bar: String) -> String {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(bar: String) -> String"
        )
        event.parameters = [
          "bar": bar
        ]
        func _foo(bar: String) -> String {
          print("Foo: \(bar)")
        }
        let result = _foo(bar: bar)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_function_withParameters_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      func foo(bar: String) -> String { 
        return "Foo: \(bar)"
      }
      """#
    } expansion: {
      #"""
      func foo(bar: String) -> String {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(bar: String) -> String"
        )
        event.parameters = [
          "bar": bar
        ]
        func _foo(bar: String) -> String {
          return "Foo: \(bar)"
        }
        let result = _foo(bar: bar)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_function_withLabeledParameters_returnsTuple() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ bar: String, baz biz: Int) -> (String, Int)"
        )
        event.parameters = [
          "bar": bar,
          "biz": biz
        ]
        func _foo(bar: String, biz: Int) -> (String, Int) {
          return ("Bar: \(bar)", biz * 2)
        }
        let result = _foo(bar: bar, biz: biz)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_mutatingFunction_withNoParameters_returnsVoid() throws {
    assertMacro {
      #"""
      @Log
      mutating func foo() { 
        self.counter += 1 
      }
      """#
    } expansion: {
      """
      mutating func foo() {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo()"
        )
        self.counter += 1
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_mutatingFunction_withParameters_returnsVoid() throws {
    assertMacro {
      #"""
      @Log
      mutating func foo(bar: String) { 
        self.bar = bar
      }
      """#
    } expansion: {
      """
      mutating func foo(bar: String) {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo(bar: String)"
        )
        event.parameters = [
          "bar": bar
        ]
        self.bar = bar
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_mutatingThrowingFunction_withNoParametres_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "mutating func foo() throws"
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
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_noParameters_returnsVoid() throws {
    assertMacro {
      #"""
      @Log
      func foo() throws {
        throw NSError()
      }
      """#
    } expansion: {
      """
      func foo() throws {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() throws"
        )
        func _foo() throws {
          throw NSError()
        }
        do {
          let _ = try _foo()
        } catch {
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_noParameters_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo() throws -> Int"
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
          event.result = result
          Loggable.default.emit(event: event)
          return result
        } catch {
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_withParameters_returnsVoid() throws {
    assertMacro {
      #"""
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
      func foo(_ value: Int) throws {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ value: Int) throws"
        )
        event.parameters = [
          "value": value
        ]
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
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_throwingFunction_withParameters_returnsTuple() throws {
    assertMacro {
      #"""
      @Log
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func foo(_ value: Int, content: String) throws -> (Int, String)"
        )
        event.parameters = [
          "value": value,
          "content": content
        ]
        func _foo(value: Int, content: String) throws -> (Int, String) {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return (value, "\(content): \(value)")
          }
        }
        do {
          let result = try _foo(value: value, content: content)
          event.result = result
          Loggable.default.emit(event: event)
          return result
        } catch {
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """#
    }
  }

  func test_asyncThrowingFunction_noParametres_returnsVoid() throws {
    assertMacro {
      #"""
      func foo() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
      }
      """#
    } expansion: {
      """
      func foo() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
      }
      """
    }
  }

  func test_function_withEscapingClosure_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performTask(completion: @escaping () -> Void)"
        )
        event.parameters = [
          "completion": completion
        ]
        completion()
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_function_withAutoclosureParameter_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      func check(condition: @autoclosure () -> Bool) -> Bool {
        return condition()
      }
      """#
    } expansion: {
      """
      func check(condition: @autoclosure () -> Bool) -> Bool {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func check(condition: @autoclosure () -> Bool) -> Bool"
        )
        event.parameters = [
          "condition": condition
        ]
        func _check(condition: @autoclosure () -> Bool) -> Bool {
          return condition()
        }
        let result = _check(condition: condition())
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withInoutParameter_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func update(value: inout Int, with newValue: Int)"
        )
        event.parameters = [
          "value": value,
          "newValue": newValue
        ]
        value = newValue
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_staticFunction_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      static func staticMethod(info: String) -> String {
        return "Static: \(info)"
      }
      """#
    } expansion: {
      #"""
      static func staticMethod(info: String) -> String {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "static func staticMethod(info: String) -> String"
        )
        event.parameters = [
          "info": info
        ]
        func _staticMethod(info: String) -> String {
          return "Static: \(info)"
        }
        let result = _staticMethod(info: info)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_rethrowsFunction_returnsVoid() throws {
    assertMacro {
      #"""
      @Log
      func execute(operation: () throws -> Void) rethrows {
        try operation()
      }
      """#
    } expansion: {
      """
      func execute(operation: () throws -> Void) rethrows {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func execute(operation: () throws -> Void) rethrows"
        )
        event.parameters = [
          "operation": operation
        ]
        func _execute(operation: () throws -> Void) rethrows {
          try operation()
        }
        do {
          let _ = try _execute(operation: operation)
        } catch {
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_function_withClosureParameter_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      func transform(value: Int, using transform: (Int) -> String) -> String {
        return transform(value)
      }
      """#
    } expansion: {
      """
      func transform(value: Int, using transform: (Int) -> String) -> String {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func transform(value: Int, using transform: (Int) -> String) -> String"
        )
        event.parameters = [
          "value": value,
          "transform": transform
        ]
        func _transform(value: Int, transform: (Int) -> String) -> String {
          return transform(value)
        }
        let result = _transform(value: value, transform: transform)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_genericFunction_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      func identity<T>(_ value: T) -> T {
        return value
      }
      """#
    } expansion: {
      """
      func identity<T>(_ value: T) -> T {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func identity<T>(_ value: T) -> T"
        )
        event.parameters = [
          "value": value
        ]
        func _identity(value: T) -> T {
          return value
        }
        let result = _identity(value: value)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_genericFunction_withWhereClause_returnsTuple() throws {
    assertMacro {
      #"""
      @Log
      func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible {
        return (first, second)
      }
      """#
    } expansion: {
      """
      func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible"
        )
        event.parameters = [
          "first": first,
          "second": second
        ]
        func _combine(first: T, second: U) -> (T, U) {
          return (first, second)
        }
        let result = _combine(first: first, second: second)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withDefaultParameters_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: #"func greet(name: String = "Guest") -> String"#
        )
        event.parameters = [
          "name": name
        ]
        func _greet(name: String) -> String {
          return "Hello, \(name)!"
        }
        let result = _greet(name: name)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_function_withVariadicParameters_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func sum(numbers: Int...) -> Int"
        )
        event.parameters = [
          "numbers": numbers
        ]
        func _sum(numbers: Int...) -> Int {
          return numbers.reduce(0, +)
        }
        let result = _sum(numbers: numbers)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withMultipleAttributes_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      @discardableResult
      func compute(value: Int) -> Int {
        return value * value
      }
      """#
    } expansion: {
      """
      @discardableResult
      func compute(value: Int) -> Int {
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func compute(value: Int) -> Int"
        )
        event.parameters = [
          "value": value
        ]
        func _compute(value: Int) -> Int {
          return value * value
        }
        let result = _compute(value: value)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_returningClosure_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func makeIncrementer() -> (Int) -> Int"
        )
        func _makeIncrementer() -> (Int) -> Int {
          return {
            $0 + 1
          }
        }
        let result = _makeIncrementer()
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withAsyncClosureParameter_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func fetchData(completion: @escaping () async -> String)"
        )
        event.parameters = [
          "completion": completion
        ]
        Task {
            let data = await completion()
            print(data)
          }
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_function_withMainActor_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func updateUI(message: String)"
        )
        event.parameters = [
          "message": message
        ]
        print(message)
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_genericFunction_withMultipleConstraints_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool"
        )
        event.parameters = [
          "first": first,
          "second": second
        ]
        func _process(first: T, second: U) -> Bool {
          return true
        }
        let result = _process(first: first, second: second)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_objcFunction_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performAction()"
        )
        print("Action performed")
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_function_withNoParametes_returnsOptionalValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func getOptionalValue() -> Int?"
        )
        func _getOptionalValue() -> Int? {
          return nil
        }
        let result = _getOptionalValue()
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withAsyncThrowingClosureParameter_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String"
        )
        event.parameters = [
          "completion": completion
        ]
        func _performAsyncTask(completion: @escaping () async throws -> String) async throws -> String {
          return try await completion()
        }
        do {
          let result = try await _performAsyncTask(completion: completion)
          event.result = result
          Loggable.default.emit(event: event)
          return result
        } catch {
          event.error = error
          Loggable.default.emit(event: event)
          throw error
        }
      }
      """
    }
  }

  func test_overridingFunction_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "override func description() -> String"
        )
        func _description() -> String {
          return "Override"
        }
        let result = _description()
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withInoutAndDefaultParameter_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func updateScore(score: inout Int, increment: Int = 1)"
        )
        event.parameters = [
          "score": score,
          "increment": increment
        ]
        score += increment
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_function_withOptionalParameters_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func optionalTest(value: String?) -> String"
        )
        event.parameters = [
          "value": value
        ]
        func _optionalTest(value: String?) -> String {
          return value ?? "Default"
        }
        let result = _optionalTest(value: value)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_genericFunction_withComplexSignature_returnsValue() throws {
    assertMacro {
      #"""
      @Log
      func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]
        where T: Comparable, U: Comparable
      {
        return []
      }
      """#
    } expansion: {
      #"""
      func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]
        where T: Comparable, U: Comparable{
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]\n  where T: Comparable, U: Comparable"
        )
        event.parameters = [
          "first": first,
          "second": second
        ]
        func _merge(first: [T], second: [U]) -> [(T, U)]
        {
          return []
        }
        let result = _merge(first: first, second: second)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_function_withClosureDefaultValue_returnsVoid() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func perform(action: (() -> Void)? = nil)"
        )
        event.parameters = [
          "action": action
        ]
        action?()
        Loggable.default.emit(event: event)
      }
      """
    }
  }

  func test_staticGenericFunction_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "static func create<T>(value: T) -> [T]"
        )
        event.parameters = [
          "value": value
        ]
        func _create(value: T) -> [T] {
          return [value]
        }
        let result = _create(value: value)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }

  func test_function_withTupleParameter_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func process(pair: (Int, String)) -> String"
        )
        event.parameters = [
          "pair": pair
        ]
        func _process(pair: (Int, String)) -> String {
          return "\(pair.0) - \(pair.1)"
        }
        let result = _process(pair: pair)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """#
    }
  }

  func test_function_withGenericClosureParameter_returnsValue() throws {
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
        var event = Loggable.Event(
          location: "TestModule/Test.swift:1:1",
          declaration: "func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T]"
        )
        event.parameters = [
          "elements": elements,
          "predicate": predicate
        ]
        func _filterElements(elements: [T], predicate: (T) -> Bool) -> [T] {
          return elements.filter(predicate)
        }
        let result = _filterElements(elements: elements, predicate: predicate)
        event.result = result
        Loggable.default.emit(event: event)
        return result
      }
      """
    }
  }
}
