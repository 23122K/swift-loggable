import LoggableMacro
import MacroTesting
import Testing

@Suite(
  .macros(
    [OSLoggerMacro.self],
    indentationWidth: .spaces(2),
    record: .missing
  )
)
struct OSLoggerTests {
  @Test
  func class_default_openAccessModifier() {
    assertMacro {
      """
      @OSLogger
      open class Foo {}
      """
    } expansion: {
      """
      open class Foo {}

      extension Foo: {
        nonisolated public static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo"
        )
      }
      """
    }
  }

  @Test
  func class_default_finalAccessModifer() {
    assertMacro {
      """
      @OSLogger
      final class Foo {}
      """
    } expansion: {
      """
      final class Foo {}

      extension Foo: {
        nonisolated internal static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo"
        )
      }
      """
    }
  }

  @Test
  func struct_default_privateAccessModifer() {
    assertMacro {
      """
      @OSLogger
      private struct Foo {}
      """
    } expansion: {
      """
      private struct Foo {}

      extension Foo: {
        nonisolated private static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo"
        )
      }
      """
    }
  }

  @Test
  func enum_default_filePrivateAccessModifer() {
    assertMacro {
      """
      @OSLogger
      fileprivate struct Foo {}
      """
    } expansion: {
      """
      fileprivate struct Foo {}

      extension Foo: {
        nonisolated fileprivate static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo"
        )
      }
      """
    }
  }

  @Test
  func extension_default_privateAccessModifer() {
    assertMacro {
      """
      @OSLogger
      private extension Foo {}
      """
    } expansion: {
      """
      private extension Foo {}

      extension Foo: {
        nonisolated private static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo "
        )
      }
      """
    }
  }

  @Test
  func actor_default_internalAccessModifier() {
    assertMacro {
      """
      @OSLogger
      private extension Foo {}
      """
    } expansion: {
      """
      private extension Foo {}

      extension Foo: {
        nonisolated private static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo "
        )
      }
      """
    }
  }

  @Test
  func mainActorStruct_withCustomAccessLevel_internalAccessModifier() {
    assertMacro {
      """
      @MainActor
      @OSLogger(access: .fileprivate)
      public struct Foo {}
      """
    } expansion: {
      """
      @MainActor
      public struct Foo {}

      extension Foo: {
        nonisolated fileprivate static let logger: Logger = Logger(
          subsystem: Bundle.main.bundleIdentifier ?? "",
          category: "Foo"
        )
      }
      """
    }
  }

  @Test
  func genericEnum_withCustomSubsystemAndCategory_privateAccessModifier() {
    assertMacro {
      """
      @OSLogger(subsystem: "OSLogerMacroTests", category: "enum")
      public enum Foo<T> {}
      """
    } expansion: {
      """
      public enum Foo<T> {}

      extension Foo: {
        nonisolated public static var logger: Logger {
          Logger(
            subsystem: "OSLogerMacroTests",
            category: "enum"
          )
        }
      }
      """
    }
  }

  @Test
  func genericExtension_withCustomAccessLevel_privateAccessModifier() {
    assertMacro {
      """
      @OSLogger(access: .public)
      private extension Foo where T: Equatable {}
      """
    } expansion: {
      """
      private extension Foo where T: Equatable {}

      extension Foo: {
        nonisolated public static var logger: Logger {
          Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "",
            category: "Foo "
          )
        }
      }
      """
    }
  }
}
