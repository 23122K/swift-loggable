import Foundation
import Testing
@testable import CountMeIn

@MainActor
struct CountMeInTests {
  @Test func shouldFetchRandomFact() async throws {
    let storageClient = StorageClient(context: .test)
    var apiClient = ApiClient.test
    
    let mathUrl = URL.fact(for: .math)
    apiClient.override(url: mathUrl) {
      let fact = Fact(kind: .math)
      return try await ApiClient.mock(fact, for: mathUrl)
    }
      
    let swipeableFactModel = SwipeableFactModel(
      storageClient: storageClient,
      apiClient: apiClient
    )
    
    await swipeableFactModel.factKindSelected(.math)
    #expect(swipeableFactModel.factKind == Fact.Kind.math)
    
    try await swipeableFactModel.getRandomFact()
    #expect(swipeableFactModel.fact.value != nil)
    
    await swipeableFactModel.factKindSelected(.year)
    #expect(swipeableFactModel.factKind == Fact.Kind.year)
  }
}
