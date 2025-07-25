enum Loadable<T> {
  case loading
  case content(T)
  case failure
  
  var value: T? {
    guard case let .content(value) = self else { return nil }
    return value
  }
}

extension Loadable: Equatable where T: Equatable {}
extension Loadable: Hashable where T: Hashable {}
