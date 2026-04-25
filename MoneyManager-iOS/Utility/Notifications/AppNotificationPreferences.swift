//
//  AppNotificationPreferences.swift
//  MoneyManager-iOS
//
//  Created by Codex on 25/4/26.
//

import Foundation

struct AppNotificationPreferences: Equatable {
    static let defaultReminderHour = 20
    static let defaultReminderMinute = 0

    var notificationsEnabled: Bool
    var budgetAlertsEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int

    init(
        notificationsEnabled: Bool = false,
        budgetAlertsEnabled: Bool = false,
        reminderHour: Int = AppNotificationPreferences.defaultReminderHour,
        reminderMinute: Int = AppNotificationPreferences.defaultReminderMinute
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.budgetAlertsEnabled = budgetAlertsEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }
}

extension AppNotificationPreferences {
    private enum Keys {
        static let notificationsEnabled = "notification.preferences.enabled"
        static let budgetAlertsEnabled = "notification.preferences.budgetAlertsEnabled"
        static let reminderHour = "notification.preferences.reminderHour"
        static let reminderMinute = "notification.preferences.reminderMinute"
    }

    static func load(from defaults: UserDefaults = .standard) -> AppNotificationPreferences {
        let storedHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? defaultReminderHour
        let storedMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? defaultReminderMinute

        return AppNotificationPreferences(
            notificationsEnabled: defaults.bool(forKey: Keys.notificationsEnabled),
            budgetAlertsEnabled: defaults.bool(forKey: Keys.budgetAlertsEnabled),
            reminderHour: min(max(storedHour, 0), 23),
            reminderMinute: min(max(storedMinute, 0), 59)
        )
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        defaults.set(budgetAlertsEnabled, forKey: Keys.budgetAlertsEnabled)
        defaults.set(reminderHour, forKey: Keys.reminderHour)
        defaults.set(reminderMinute, forKey: Keys.reminderMinute)
    }

    var reminderComponents: DateComponents {
        DateComponents(hour: reminderHour, minute: reminderMinute)
    }

    var reminderDate: Date {
        let calendar = Calendar.current
        return calendar.date(from: reminderComponents) ?? calendar.date(from: DateComponents(hour: Self.defaultReminderHour)) ?? .now
    }

    mutating func updateReminderTime(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        reminderHour = components.hour ?? Self.defaultReminderHour
        reminderMinute = components.minute ?? Self.defaultReminderMinute
    }

    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: reminderDate)
    }
}
