import SwiftUI
import Sentry

@main
struct CountMeInApp: App  {
  @UIApplicationDelegateAdaptor(CountMeInAppDelegate.self) private var countMeInAppDelegate
  @State var swipableFactModel = SwipeableFactModel()
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        SwipeableFactView(swipeableFactModel: self.swipableFactModel)
      }
    }
  }
}

final private class CountMeInAppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    SentrySDK.start { options in
      options.dsn = ""
      options.debug = true
    }
    
    return true
  }
}
