import Foundation
import Loggable
import SwiftData

struct ApiClient: Sendable {
  var request: @Sendable (URL) async throws -> (Data, URLResponse)
  
  func fetch<T>(
    _ url: URL,
    decoder: JSONDecoder = JSONDecoder(),
    isolation: isolated (any Actor)? = #isolation
  ) async throws -> T where T: Decodable {
    let (data, response) = try await self.request(url)
   
    guard
      let statusCode = (response as? HTTPURLResponse)?.statusCode,
      200...299 ~= statusCode
    else { throw URLError(.badServerResponse) }

    return try decoder.decode(T.self, from: data)
  }
}

extension ApiClient {
  static let live = ApiClient(
    request: { url in
      try await URLSession.shared.data(from: url)
    }
  )
}

extension URL {
  static func fact(for kind: Fact.Kind) -> Self {
    Self(string: "http://numbersapi.com/random/\(kind.rawValue)?json")!
  }
}

extension Omittable where Self == Omit {
  static var decoder: Self {
    Omit.parameter("decoder")
  }
}
