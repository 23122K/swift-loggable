import Foundation

struct Testcase {
  enum Failure: Error {
    case `default`
  }
  
  func throwingFunction() throws {
    throw Failure.default
  }
  
  static func staticThrowingFunction() throws -> Void {
    throw Failure.default
  }
  
  func asyncThrowingFunction() async throws {
    try await Task.sleep(for: .seconds(1))
    throw Failure.default
  }
  
  init() {}
}
