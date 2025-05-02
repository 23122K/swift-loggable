import LoggableMacro
import MacroTesting
import XCTest

final class OSLoggerTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      indentationWidth: .spaces(2),
      record: .missing,
      macros: ["OSLoggerMacro": OSLoggerMacro.self]
    ) {
      super.invokeTest()
    }
  }
}
