import Foundation

open class Loggable: @unchecked Sendable {
  open func message(location: String) {
    print(location)
  }
  
  public static let `default` = Loggable()
  public init() { }
}

@attached(body)
public macro Log(using loggable: Loggable = .default) = #externalMacro(module: "Macros", type: "LogMacro")

@attached(body)
public macro Omit() = #externalMacro(module: "Macros", type: "OmitMacro")

@attached(memberAttribute)
public macro Logged(using loggable: Loggable = .default) = #externalMacro(module: "Macros", type: "LoggedMacro")
