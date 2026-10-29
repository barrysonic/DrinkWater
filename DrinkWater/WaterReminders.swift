import SwiftUI
import UserNotifications

/// iOS delivers these daily calendar notifications even when the app is closed.
@MainActor
final class WaterReminders: ObservableObject {
    @Published private(set) var isEnabled = UserDefaults.standard.bool(forKey: "waterRemindersEnabled")
    @Published private(set) var isBusy = false
    @Published private(set) var needsSettings = false
    @Published private(set) var message: String?

    private let center = UNUserNotificationCenter.current()
    private let hours = Array(stride(from: 8, through: 22, by: 2))
    private var identifiers: [String] { hours.map { "drinkwater.reminder.\($0)" } }

    func refresh() async {
        guard !isBusy else { return }
        let settings = await center.notificationSettings()
        needsSettings = settings.authorizationStatus == .denied
        if isEnabled {
            // Reconcile permissions and restore the schedule after returning to the app.
            await setEnabled(true)
        }
    }

    func setEnabled(_ enabled: Bool) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        message = nil

        guard enabled else {
            clearSchedule()
            persist(false)
            return
        }

        do {
            var settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try await center.requestAuthorization(options: [.alert, .sound])
                settings = await center.notificationSettings()
            }
            needsSettings = settings.authorizationStatus == .denied
            guard [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus) else {
                clearSchedule()
                persist(false)
                message = "Pozwól na powiadomienia w ustawieniach iPhone’a, aby włączyć przypomnienia."
                return
            }

            for hour in hours {
                let content = UNMutableNotificationContent()
                content.title = "Czas na szklankę wody"
                content.body = "Zrób małą przerwę, napij się wody i zaznacz szklankę w DrinkWater."
                content.sound = .default
                var date = DateComponents()
                date.hour = hour
                date.minute = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "drinkwater.reminder.\(hour)", content: content, trigger: trigger
                )
                try await center.add(request)
            }
            persist(true)
            if settings.soundSetting != .enabled {
                message = "Przypomnienia są włączone, ale dźwięk jest wyłączony w ustawieniach powiadomień."
            }
        } catch {
            clearSchedule()
            persist(false)
            message = "Nie udało się włączyć przypomnień. Spróbuj ponownie."
        }
    }

    private func persist(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "waterRemindersEnabled")
    }

    private func clearSchedule() {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}

/// Also show reminders while DrinkWater is open.
final class WaterNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
