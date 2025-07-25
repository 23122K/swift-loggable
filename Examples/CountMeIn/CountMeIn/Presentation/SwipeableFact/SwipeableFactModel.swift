import Foundation
import Observation
import Loggable

@MainActor
@Observable
@Logged(using: .sentry)
class SwipeableFactModel {
  let storageClient: StorageClient
  var apiClient: ApiClient
  
  var fact: Loadable<Fact>
  var factKind: Fact.Kind
  var destination: Destination?
  
  func getRandomFact() async throws {
    do {
      self.fact = .loading
      let url: URL = .fact(for: self.factKind)
      self.fact = .content(
        try await self.apiClient.fetch(url)
      )
    } catch {
      self.fact = .failure
      throw error
    }
  }
 
  @Log(level: .sentryDebug)
  func onSwipeToRight(_ fact: sending Fact) async throws {
    fact.isFavorite = true
    try self.storageClient.save(fact)
    try await getRandomFact()
  }
 
  @Omit
  func factKindSelected(_ kind: Fact.Kind) async  {
    self.factKind = kind
  }
  
  func showFavoritedFactsButtonTapped() {
    self.destination = .favoriteFacts(
      FavoriteFactsModel()
    )
  }
  
  init(
    storageClient: StorageClient = StorageClient.live,
    apiClient: ApiClient = ApiClient.live,
    fact: Loadable<Fact> = .loading,
    factKind: Fact.Kind = .trivia,
    isLoading: Bool = false,
  ) {
    self.storageClient = storageClient
    self.apiClient = apiClient
    self.factKind = factKind
    self.fact = fact
  }
}

extension SwipeableFactModel {
  enum Destination {
    case favoriteFacts(FavoriteFactsModel)
  }
}

extension SwipeableFactModel.Destination: Identifiable {
  var id: ObjectIdentifier {
    switch self {
      case let .favoriteFacts(favoriteFactsModel):
        return favoriteFactsModel.id
    }
  }
}
