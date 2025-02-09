// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-loggable",
  platforms: [
    .macOS(.v12),
    .iOS(.v18)
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
      branch: "main"
    )
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
      dependencies: ["LoggableMacro"]
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
        )
      ]
    ),
  ]
)
