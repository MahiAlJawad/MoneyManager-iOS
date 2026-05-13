//
//  AppNotificationPreferences.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 25/4/26.
//

import Foundation

struct AppNotificationPreferences: Equatable {
    static let defaultReminderHour = 20
    static let defaultReminderMinute = 0
    static let maximumCustomRangeLengthInDays = 31

    var notificationsEnabled: Bool
    var notificationsDisabledBySystemRevocation: Bool
    var budgetAlertsEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var customRangeStartDate: Date?
    var customRangeEndDate: Date?

    init(
        notificationsEnabled: Bool = false,
        notificationsDisabledBySystemRevocation: Bool = false,
        budgetAlertsEnabled: Bool = false,
        reminderHour: Int = AppNotificationPreferences.defaultReminderHour,
        reminderMinute: Int = AppNotificationPreferences.defaultReminderMinute,
        customRangeStartDate: Date? = nil,
        customRangeEndDate: Date? = nil
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationsDisabledBySystemRevocation = notificationsDisabledBySystemRevocation
        self.budgetAlertsEnabled = budgetAlertsEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.customRangeStartDate = customRangeStartDate
        self.customRangeEndDate = customRangeEndDate
    }
}

extension AppNotificationPreferences {
    private enum Keys {
        static let notificationsEnabled = "notification.preferences.enabled"
        static let notificationsDisabledBySystemRevocation = "notification.preferences.disabledBySystemRevocation"
        static let budgetAlertsEnabled = "notification.preferences.budgetAlertsEnabled"
        static let reminderHour = "notification.preferences.reminderHour"
        static let reminderMinute = "notification.preferences.reminderMinute"
        static let customRangeStartDate = "notification.preferences.customRangeStartDate"
        static let customRangeEndDate = "notification.preferences.customRangeEndDate"
    }

    static func load(from defaults: UserDefaults = .standard) -> AppNotificationPreferences {
        let storedHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? defaultReminderHour
        let storedMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? defaultReminderMinute

        return AppNotificationPreferences(
            notificationsEnabled: defaults.bool(forKey: Keys.notificationsEnabled),
            notificationsDisabledBySystemRevocation: defaults.bool(forKey: Keys.notificationsDisabledBySystemRevocation),
            budgetAlertsEnabled: defaults.bool(forKey: Keys.budgetAlertsEnabled),
            reminderHour: min(max(storedHour, 0), 23),
            reminderMinute: min(max(storedMinute, 0), 59),
            customRangeStartDate: defaults.object(forKey: Keys.customRangeStartDate) as? Date,
            customRangeEndDate: defaults.object(forKey: Keys.customRangeEndDate) as? Date
        )
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        defaults.set(notificationsDisabledBySystemRevocation, forKey: Keys.notificationsDisabledBySystemRevocation)
        defaults.set(budgetAlertsEnabled, forKey: Keys.budgetAlertsEnabled)
        defaults.set(reminderHour, forKey: Keys.reminderHour)
        defaults.set(reminderMinute, forKey: Keys.reminderMinute)
        defaults.set(customRangeStartDate, forKey: Keys.customRangeStartDate)
        defaults.set(customRangeEndDate, forKey: Keys.customRangeEndDate)
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

    var hasActiveCustomRange: Bool {
        customRangeDateInterval != nil
    }

    var customRangeDateInterval: ClosedRange<Date>? {
        guard
            let start = customRangeStartDate,
            let end = customRangeEndDate
        else {
            return nil
        }

        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)

        guard normalizedStart <= normalizedEnd else {
            return nil
        }

        let daySpan = calendar.dateComponents([.day], from: normalizedStart, to: normalizedEnd).day ?? 0
        guard daySpan < Self.maximumCustomRangeLengthInDays else {
            return nil
        }

        return normalizedStart...normalizedEnd
    }

    mutating func setCustomRange(from startDate: Date, to endDate: Date, calendar: Calendar = .current) {
        customRangeStartDate = calendar.startOfDay(for: startDate)
        customRangeEndDate = calendar.startOfDay(for: endDate)
    }

    mutating func clearCustomRange() {
        customRangeStartDate = nil
        customRangeEndDate = nil
    }
}
