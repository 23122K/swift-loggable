import SwiftUI

struct SwipeableFactCard: View {
  let fact: Fact
  let onSwipeLeft: @Sendable () async -> Void
  let onSwipeRight: () async -> Void
  let color: Color
  
  @State private var offset: CGSize = .zero
  @State private var isPerformingOperation = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: .primary) {
      Text("\(fact.number)")
        .font(.largeTitle)
        .fontWeight(.semibold)
      
      GroupBox("Fact") {
        Text("\(fact.text)")
      }
      
      if let year = fact.year {
        GroupBox("Year") {
          Text("\(year)")
        }
      }
      
      if let date = fact.date {
        GroupBox("Date") {
          Text(date)
        }
      }

      GroupBox("Fact kind") {
        Text(fact.kind.title)
      }
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .topLeading
    )
    .colorInvert()
    .groupBoxStyle(.primary)
    .padding()
    .background(self.color)
    .cornerRadius(.primary)
    .offset(offset)
    .rotationEffect(.degrees(Double(offset.width / 20)))
    .gesture(
      DragGesture()
        .onChanged { gesture in
          offset = gesture.translation
        }
        .onEnded { gesture in
          handleSwipe(translation: gesture.translation)
        }
    )
    .animation(.spring(), value: offset)
  }
  
  private func handleSwipe(translation: CGSize) {
    let threshold: CGFloat = 200
    
    if translation.width < -threshold {
      Task(operation: self.onSwipeLeft)
    } else if translation.width > threshold {
      Task { await self.onSwipeRight() }
      offset = .zero
    } else {
      offset = .zero
    }
  }
  
  init(
    fact: Fact,
    _ onSwipeLeft: @escaping @Sendable () async -> Void,
    onSwipeRight: @escaping () async -> Void,
    color: Color = Color.presentable.randomElement()!
  ) {
    self.fact = fact
    self.onSwipeLeft = onSwipeLeft
    self.onSwipeRight = onSwipeRight
    self.color = color
  }
}

extension Fact.Kind {
  var title: String {
    switch self {
      case .trivia:
        return "Trivia"
        
      case .year:
        return "Year"
        
      case .date:
        return "Date"
        
      case .math:
        return "Math"
    }
  }
}

extension Color {
  static let presentable: [Color] = [
    Color.blue,
    Color.red,
    Color.green,
    Color.purple,
    Color.pink
  ]
}
