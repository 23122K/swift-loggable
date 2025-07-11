import SwiftUI

struct FavoriteFactsView: View {
  @Bindable var favoriteFactsModel: FavoriteFactsModel
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(self.favoriteFactsModel.facts.reversed()) { fact in
          GroupBox("Fact for \(fact.number) • \(fact.kind.title)") {
            Text(fact.text)
          }
          .groupBoxStyle(.primary)
          .swipeActions(allowsFullSwipe: true) {
            Button(role: .destructive) {
              Task {
                try? self.favoriteFactsModel.deleteFromFavoriteButtonTapped(fact)
              }
            } label: {
              Label {
                Text("Remove from favorites")
              } icon: {
                Image(systemName: "heart.slash")
              }
            }
          }
        }
      }
      .navigationTitle("Favorite")
      .navigationBarTitleDisplayMode(.large)
      .scrollIndicators(.hidden)
      .presentationDragIndicator(.visible)
      .toolbar {
        Button("Delete all") {
          Task {
            try? self.favoriteFactsModel.deleteAllFavoriteFacts()
          }
        }
      }
      .onAppear {
        try? self.favoriteFactsModel.fetchFavoriteFacts()
      }
    }
  }
  
  init(favoriteFactsModel: FavoriteFactsModel) {
    self.favoriteFactsModel = favoriteFactsModel
  }
}
