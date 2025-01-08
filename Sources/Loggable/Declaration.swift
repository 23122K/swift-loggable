import Foundation
import OSLog

@attached(body)
public macro Log() = #externalMacro(module: "Macros", type: "LogMacro")
