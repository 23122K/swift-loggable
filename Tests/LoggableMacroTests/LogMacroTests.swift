import LoggableMacro
import MacroTesting
import XCTest

final class LogMacroTests: XCTestCase {
  override func invokeTest() {
      withMacroTesting(
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
        func _foo() {
          print("Foo")
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo()")
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
        func _foo() {
          print("Foo")
        }
        CustomLogger().log(location: "TestModule/Test.swift:1:1", of: "func foo()")
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
        func _foo() {
          print("Foo")
        }
        Loggable.custom.log(location: "TestModule/Test.swift:1:1", of: "func foo()")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo() -> String")
        let result = _foo()
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo(bar: String) -> String")
        let result = _foo(bar: bar)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo(bar: String) -> String")
        let result = _foo(bar: bar)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo(_ bar: String, baz biz: Int) -> (String, Int)")
        let result = _foo(bar: bar, biz: biz)
        Loggable.default.log(result: result)
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
        func _foo() {
          self.counter += 1
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "mutating func foo()")
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
        func _foo(bar: String) {
          self.bar = bar
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "mutating func foo(bar: String)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "mutating func foo() throws")
        do {
          let _ = try _foo()
        } catch {
          Loggable.default.log(error: error)
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
      #"""
      func foo() throws {
        func _foo() throws {
          throw NSError()
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo() throws")
        do {
          let _ = try _foo()
        } catch {
          Loggable.default.log(error: error)
          throw error
        }
      }
      """#
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
      #"""
      func foo() throws -> Int {
        func _foo() throws -> Int {
          if Bool.random() {
            throw NSError(domain: com.foo.test, code: .zero)
          } else {
            return .zero
          }
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo() throws -> Int")
        do {
          let result = try _foo()
          Loggable.default.log(result: result)
          return result
        } catch {
          Loggable.default.log(error: error)
          throw error
        }
      }
      """#
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo(_ value: Int) throws")
        do {
          let _ = try _foo(value: value)
        } catch {
          Loggable.default.log(error: error)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func foo(_ value: Int, content: String) throws -> (Int, String)")
        do {
          let result = try _foo(value: value, content: content)
          Loggable.default.log(result: result)
          return result
        } catch {
          Loggable.default.log(error: error)
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
  
  func test_asyncThorwingFunction_withParameter_returnsVoid() throws {
    
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
        func _performTask(completion: @escaping () -> Void) {
          completion()
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func performTask(completion: @escaping () -> Void)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func check(condition: @autoclosure () -> Bool) -> Bool")
        let result = _check(condition: condition())
        Loggable.default.log(result: result)
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
        func _update(value: inout Int, newValue: Int) {
          value = newValue
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func update(value: inout Int, with newValue: Int)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "static func staticMethod(info: String) -> String")
        let result = _staticMethod(info: info)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func execute(operation: () throws -> Void) rethrows")
        do {
          let _ = try _execute(operation: operation)
        } catch {
          Loggable.default.log(error: error)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func transform(value: Int, using transform: (Int) -> String) -> String")
        let result = _transform(value: value, transform: transform)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func identity<T>(_ value: T) -> T")
        let result = _identity(value: value)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func combine<T, U>(first: T, second: U) -> (T, U) where T: CustomStringConvertible, U: CustomStringConvertible")
        let result = _combine(first: first, second: second)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: #"func greet(name: String = "Guest") -> String"#)
        let result = _greet(name: name)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func sum(numbers: Int...) -> Int")
        let result = _sum(numbers: numbers)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func compute(value: Int) -> Int")
        let result = _compute(value: value)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func makeIncrementer() -> (Int) -> Int")
        let result = _makeIncrementer()
        Loggable.default.log(result: result)
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
        func _fetchData(completion: @escaping () async -> String) {
          Task {
            let data = await completion()
            print(data)
          }
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func fetchData(completion: @escaping () async -> String)")
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
        func _updateUI(message: String) {
          print(message)
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func updateUI(message: String)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func process<T: Equatable, U: Numeric>(first: T, second: U) -> Bool")
        let result = _process(first: first, second: second)
        Loggable.default.log(result: result)
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
        func _performAction() {
          print("Action performed")
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func performAction()")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func getOptionalValue() -> Int?")
        let result = _getOptionalValue()
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func performAsyncTask(completion: @escaping () async throws -> String) async throws -> String")
        do {
          let result = try await _performAsyncTask(completion: completion)
          Loggable.default.log(result: result)
          return result
        } catch {
          Loggable.default.log(error: error)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "override func description() -> String")
        let result = _description()
        Loggable.default.log(result: result)
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
        func _updateScore(score: inout Int, increment: Int) {
          score += increment
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func updateScore(score: inout Int, increment: Int = 1)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func optionalTest(value: String?) -> String")
        let result = _optionalTest(value: value)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func merge<T, U>(_ first: [T], with second: [U]) -> [(T, U)]\n  where T: Comparable, U: Comparable")
        let result = _merge(first: first, second: second)
        Loggable.default.log(result: result)
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
        func _perform(action: (() -> Void)?) {
          action?()
        }
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func perform(action: (() -> Void)? = nil)")
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "static func create<T>(value: T) -> [T]")
        let result = _create(value: value)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func process(pair: (Int, String)) -> String")
        let result = _process(pair: pair)
        Loggable.default.log(result: result)
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
        Loggable.default.log(location: "TestModule/Test.swift:1:1", of: "func filterElements<T>(elements: [T], using predicate: (T) -> Bool) -> [T]")
        let result = _filterElements(elements: elements, predicate: predicate)
        Loggable.default.log(result: result)
        return result
      }
      """
    }
  }
}
