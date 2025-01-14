import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(Macros)
import Macros

let testMacros: [String: Macro.Type] = [
  "Log": LogMacro.self,
  "Logged": LoggedMacro.self,
  "Omit": OmitMacro.self
]
#endif

final class swift_loggableTests: XCTestCase {
    func testMacro() throws {
        #if canImport(Macros)
        assertMacroExpansion(
            """
            @Log(using: .default)
            func bar() {
              print("X")
            }
            """,
            expandedSource: """
            struct Foo {
            }
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
