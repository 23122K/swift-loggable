import Foundation

extension Result {
  var isSuccess: Bool {
    guard case .success = self
    else { return false }
    return true
  }

  var description: String {
    switch self {
    case let .success(value) where value is Void:
      return "Void"

    case let .success(value):
      return "\(value)"

    case let .failure(error):
      return "\(error)"
    }
  }
}
