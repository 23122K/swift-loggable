import Foundation

struct Unimplemented: LocalizedError {
  let errorDescription: String?
  
  init(_ errorDescription: String?) {
    self.errorDescription = errorDescription
  }
}
