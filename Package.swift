// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-loggable",
  platforms: [
    .macOS(.v14),
    .iOS(.v18)
  ],
  products: [
    .library(
      name: "Loggable",
      targets: ["Loggable"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-syntax.git",
      from: "600.0.0-latest"
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
      dependencies: ["LoggableMacro"]
    ),
    .testTarget(
      name: "LoggableTests",
      dependencies: [
        "LoggableMacro",
        .product(
          name: "SwiftSyntaxMacrosTestSupport",
          package: "swift-syntax"
        )
      ]
    ),
  ]
)
