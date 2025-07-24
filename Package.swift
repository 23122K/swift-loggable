// swift-tools-version: 6.0
import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-loggable",
  platforms: [
    .macOS(.v12),
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "Loggable",
      targets: ["Loggable"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-syntax.git",
      from: "600.0.0-latest"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-macro-testing.git",
      from: "0.6.3"
    ),
    .package(
      url: "https://github.com/swiftlang/swift-docc-plugin",
      from: "1.4.4"
    ),
  ],
  targets: [
    .macro(
      name: "LoggableMacro",
      dependencies: [
        .product(
          name: "SwiftSyntaxMacros",
          package: "swift-syntax"
        ),
        .product(
          name: "SwiftCompilerPlugin",
          package: "swift-syntax"
        )
      ]
    ),
    .target(
      name: "Loggable",
      dependencies: [
        "LoggableMacro"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .executableTarget(
      name: "Client",
      dependencies: [
        "Loggable"
      ]
    ),
    .testTarget(
      name: "LoggableMacroTests",
      dependencies: [
        "LoggableMacro",
        .product(
          name: "SwiftSyntaxMacrosTestSupport",
          package: "swift-syntax"
        ),
        .product(
          name: "MacroTesting",
          package: "swift-macro-testing"
        ),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
