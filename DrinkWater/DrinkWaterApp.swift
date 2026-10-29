import SwiftUI
import UserNotifications

@main
struct DrinkWaterApp: App {
    private let notificationDelegate = WaterNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
