import SwiftData

extension ModelContainer {
  static let live = {
    try! ModelContainer(
      for: Fact.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: false)
    )
  }()
  
  static let test = {
    try! ModelContainer(
      for: Fact.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
  }()
}

extension ModelContext {
  @MainActor
  static let live: ModelContext = {
    ModelContext(.live)
  }()
  
  @MainActor
  static let test: ModelContext = {
    ModelContext(.test)
  }()
}
