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
        print("Foo")
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo()")
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
        print("Foo")
        CustomLogger().log(at: "TestModule/Test.swift:1:1", of: "func foo()")
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
        print("Foo")
        Loggable.custom.log(at: "TestModule/Test.swift:1:1", of: "func foo()")
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
        func _foo() -> String {
          return "Foo"
        }
        let result = _foo()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo() -> String", result: result)
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
        func _foo(bar: String) -> String {
          print("Foo: \(bar)")
        }
        let result = _foo(bar: bar)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(bar: String) -> String", result: result)
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
        func _foo(bar: String) -> String {
          return "Foo: \(bar)"
        }
        let result = _foo(bar: bar)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(bar: String) -> String", result: result)
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
        func _foo(bar: String, biz: Int) -> (String, Int) {
          return ("Bar: \(bar)", biz * 2)
        }
        let result = _foo(bar: bar, biz: biz)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(_ bar: String, baz biz: Int) -> (String, Int)", result: result)
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
        self.counter += 1
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "mutating func foo()")
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
        self.bar = bar
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "mutating func foo(bar: String)")
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
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "mutating func foo() throws", error: error)
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
        func _foo() throws {
          throw NSError()
        }
        do {
          let _ = try _foo()
        } catch {
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo() throws", error: error)
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
        func _foo() throws -> Int {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return .zero
          }
        }
        do {
          let result = try _foo()
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo() throws -> Int", result: result)
          return result
        } catch {
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo() throws -> Int", error: error)
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
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(_ value: Int) throws", error: error)
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
        func _foo(value: Int, content: String) throws -> (Int, String) {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return (value, "\(content): \(value)")
          }
        }
        do {
          let result = try _foo(value: value, content: content)
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(_ value: Int, content: String) throws -> (Int, String)", result: result)
          return result
        } catch {
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func foo(_ value: Int, content: String) throws -> (Int, String)", error: error)
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
        completion()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func performTask(completion: @escaping () -> Void)")
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
        func _check(condition: @autoclosure () -> Bool) -> Bool {
          return condition()
        }
        let result = _check(condition: condition())
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func check(condition: @autoclosure () -> Bool) -> Bool", result: result)
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
        value = newValue
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func update(value: inout Int, with newValue: Int)")
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
        func _staticMethod(info: String) -> String {
          return "Static: \(info)"
        }
        let result = _staticMethod(info: info)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "static func staticMethod(info: String) -> String", result: result)
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
        func _execute(operation: () throws -> Void) rethrows {
          try operation()
        }
        do {
          let _ = try _execute(operation: operation)
        } catch {
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func execute(operation: () throws -> Void) rethrows", error: error)
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
        func _transform(value: Int, transform: (Int) -> String) -> String {
          return transform(value)
        }
        let result = _transform(value: value, transform: transform)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func transform(value: Int, using transform: (Int) -> String) -> String", result: result)
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
        func _identity(value: T) -> T {
          return value
        }
        let result = _identity(value: value)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func identity<T>(_ value: T) -> T", result: result)
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
        func _combine(first: T, second: U) -> (T, U) {
          return (first, second)
        }
        let result = _combine(first: first, second: second)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible", result: result)
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
        func _greet(name: String) -> String {
          return "Hello, \(name)!"
        }
        let result = _greet(name: name)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: #"func greet(name: String = "Guest") -> String"#, result: result)
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
        func _sum(numbers: Int...) -> Int {
          return numbers.reduce(0, +)
        }
        let result = _sum(numbers: numbers)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func sum(numbers: Int...) -> Int", result: result)
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
        func _compute(value: Int) -> Int {
          return value * value
        }
        let result = _compute(value: value)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func compute(value: Int) -> Int", result: result)
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
        func _makeIncrementer() -> (Int) -> Int {
          return {
            $0 + 1
          }
        }
        let result = _makeIncrementer()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func makeIncrementer() -> (Int) -> Int", result: result)
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
        Task {
            let data = await completion()
            print(data)
          }
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func fetchData(completion: @escaping () async -> String)")
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
        print(message)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func updateUI(message: String)")
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
        func _process(first: T, second: U) -> Bool {
          return true
        }
        let result = _process(first: first, second: second)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool", result: result)
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
        print("Action performed")
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func performAction()")
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
        func _getOptionalValue() -> Int? {
          return nil
        }
        let result = _getOptionalValue()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func getOptionalValue() -> Int?", result: result)
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
        func _performAsyncTask(completion: @escaping () async throws -> String) async throws -> String {
          return try await completion()
        }
        do {
          let result = try await _performAsyncTask(completion: completion)
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String", result: result)
          return result
        } catch {
          Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String", error: error)
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
        func _description() -> String {
          return "Override"
        }
        let result = _description()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "override func description() -> String", result: result)
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
        score += increment
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func updateScore(score: inout Int, increment: Int = 1)")
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
        func _optionalTest(value: String?) -> String {
          return value ?? "Default"
        }
        let result = _optionalTest(value: value)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func optionalTest(value: String?) -> String", result: result)
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
        func _merge(first: [T], second: [U]) -> [(T, U)]
        {
          return []
        }
        let result = _merge(first: first, second: second)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]\n  where T: Comparable, U: Comparable", result: result)
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
        action?()
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func perform(action: (() -> Void)? = nil)")
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
        func _create(value: T) -> [T] {
          return [value]
        }
        let result = _create(value: value)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "static func create<T>(value: T) -> [T]", result: result)
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
        func _process(pair: (Int, String)) -> String {
          return "\(pair.0) - \(pair.1)"
        }
        let result = _process(pair: pair)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func process(pair: (Int, String)) -> String", result: result)
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
        func _filterElements(elements: [T], predicate: (T) -> Bool) -> [T] {
          return elements.filter(predicate)
        }
        let result = _filterElements(elements: elements, predicate: predicate)
        Loggable.default.log(at: "TestModule/Test.swift:1:1", of: "func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T]", result: result)
        return result
      }
      """
    }
  }
}
