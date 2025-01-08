// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-loggable",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v18)
  ],
  products: [
    .library(
      name: "Loggable",
      targets: ["Loggable"]
    ),
    .executable(
      name: "Client",
      targets: ["Client"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
  ],
  targets: [
    .macro(
      name: "Macros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .target(
      name: "Loggable",
      dependencies: ["Macros"]
    ),
    .executableTarget(
      name: "Client",
      dependencies: ["Loggable"]
    ),
    .testTarget(
      name: "LoggableTests",
      dependencies: [
        "Macros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
