import SwiftUI

@main
struct CountMeInApp: App {
  @State var swipableFactModel = SwipeableFactModel()
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        SwipeableFactView(swipeableFactModel: self.swipableFactModel)
      }
    }
  }
}
