import Loggable
import SwiftData

@OSLogger
@MainActor
struct StorageClient: Sendable {
  var context: () -> ModelContext
  
  init(context: @autoclosure @escaping () -> ModelContext) {
    self.context = context
  }
}

extension StorageClient {
  static let didSave = ModelContext.didSave
  static let live = StorageClient(
    context: ModelContext.live
  )
  
  static let test = StorageClient(
    context: ModelContext.test
  )
}

@OSLogged
extension StorageClient {
  func save<T: PersistentModel>(_ model: T) throws {
    self.context().insert(model)
    try self.context().save()
  }
  
  func delete<T: PersistentModel>(_ model: T) throws {
    self.context().delete(model)
    try self.context().save()
  }
  
  func fetch<T: PersistentModel>() throws -> [T] {
    try self.context()
      .fetch(FetchDescriptor<T>())
  }
}
