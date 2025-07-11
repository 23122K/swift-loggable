#if DEBUG
import Foundation

extension ApiClient {
  static let test = ApiClient(
    request: { _ in throw Unimplemented("\(Self.self).request") }
  )
  
  mutating func override(
    url: URL,
    with response: @escaping @Sendable () async throws -> (Data, URLResponse)
  ) {
    self.request = { @Sendable [self] baseUrl in
      return if baseUrl.absoluteString == url.absoluteString {
        try await response()
      } else {
        try await self.request(baseUrl)
      }
    }
  }
 
  static func mock<T: Codable>(
    _ value: T,
    for url: URL,
    statusCode: Int = 200,
    httpVersion: String = "HTTP/1.1",
    headerFields: [String: String]? = nil,
    encoder: JSONEncoder = JSONEncoder()
  ) async throws -> (Data, URLResponse) {
    try (
      encoder.encode(value),
      HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: httpVersion,
        headerFields: headerFields
      )!
    )
  }
}
#endif
