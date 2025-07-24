import SwiftUI

struct SwipeableFactView: View {
  @State var swipeableFactModel: SwipeableFactModel
  
  var body: some View {
    Group {
      switch self.swipeableFactModel.fact {
        case let .content(fact):
          SwipeableFactCard(fact: fact) {
            try? await self.swipeableFactModel.getRandomFact()
          } onSwipeRight: {
            try? await self.swipeableFactModel.onSwipeToRight(fact)
          }
          
        case .failure:
          VStack(alignment: .center, spacing: .primary) {
            Image(systemName: "multiply.circle.fill")
              .resizable()
              .scaledToFit()
              .scaleEffect(0.5)
              .foregroundStyle(Color.red)
            
            Button("Oopsie, try again!") {
              Task(operation: self.swipeableFactModel.getRandomFact)
            }
            .buttonStyle(.primary(Color.red))
          }
          .frame(maxWidth: .infinity, alignment: .top)
          
        case .loading:
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
      }
    }
    .padding(.primary)
    .task { try? await self.swipeableFactModel.getRandomFact() }
    .navigationTitle("\(self.swipeableFactModel.factKind.title) facts!")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      Button {
        self.swipeableFactModel.showFavoritedFactsButtonTapped()
      } label: {
        Image(systemName: "heart.fill")
      }
      
      Menu {
        ForEach(Fact.Kind.allCases, id: \.rawValue) { kind in
          Button {
            Task {
              try? await self.swipeableFactModel.factKindSelected(kind)
            }
          } label: {
            if self.swipeableFactModel.factKind == kind {
              Text("\(kind.title) (selected)")
            } else {
              Text(kind.title)
            }
          }
        }
      } label: {
        Image(systemName: "gear")
      }
    }
    .sheet(item: self.$swipeableFactModel.destination) { destination in
      switch destination {
        case let .favoriteFacts(favoriteFactsModel):
          FavoriteFactsView(favoriteFactsModel: favoriteFactsModel)
      }
    }
  }
  
  init(swipeableFactModel: SwipeableFactModel) {
    self.swipeableFactModel = swipeableFactModel
  }
}

