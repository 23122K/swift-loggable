import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(Macros)
import Macros

let testMacros: [String: Macro.Type] = [
    "Log": LogMacro.self
]
#endif

final class swift_loggableTests: XCTestCase {
    func testMacro() throws {
        #if canImport(Macros)
        assertMacroExpansion(
            """
            class Foo {
              static let logger = Logger(subsystem: "LoggablePlugin", category: "Log")
              
              @Log func bar(value: String, line number: Int = #line) -> Int {
                let result = bar(value: value, line: line)
              }
              
              init() {
                print("Initialised")
              }
            }
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(swift_loggableMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
