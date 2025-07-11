import Observation
import Loggable

@MainActor
@Observable
class FavoriteFactsModel: Identifiable {
  let storageClient: StorageClient
  var facts: [Fact]
  
  func fetchFavoriteFacts() throws {
    self.facts = try self.storageClient.fetch()
  }
  
  @Log(using: .printer)
  func deleteFromFavoriteButtonTapped(_ fact: sending Fact) throws {
    try self.storageClient.delete(fact)
  }
  
  init(
    facts: [Fact] = [],
    storageClient: StorageClient = StorageClient.live
  ) {
    self.facts = facts
    self.storageClient = storageClient
    
    Task {
      for await _ in NotificationCenter.default.notifications(named: StorageClient.didSave) {
        try self.fetchFavoriteFacts()
      }
    }
  }
}

extension FavoriteFactsModel {
  @Log(tag: "Deletion")
  func deleteAllFavoriteFacts() throws {
    for fact in self.facts {
      try self.storageClient.delete(fact)
    }
  }
}
