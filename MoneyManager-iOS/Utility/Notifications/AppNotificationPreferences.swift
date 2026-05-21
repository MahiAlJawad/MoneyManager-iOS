//
//  AppNotificationPreferences.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 25/4/26.
//

import Foundation

enum CustomNotificationRecurrence: String, CaseIterable {
    case once
    case daily
    case weekly
    case monthly
    case customRange
}

struct AppNotificationPreferences: Equatable {
    static let defaultReminderHour = 20
    static let defaultReminderMinute = 0
    static let maximumCustomRangeLengthInDays = 31

    var notificationsEnabled: Bool
    var notificationsDisabledBySystemRevocation: Bool
    var budgetAlertsEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var customNotificationRecurrence: CustomNotificationRecurrence
    var oneTimeNotificationDate: Date?
    var recurringNotificationStartDate: Date?
    var recurringNotificationEndDate: Date?
    var customRangeStartDate: Date?
    var customRangeEndDate: Date?

    init(
        notificationsEnabled: Bool = false,
        notificationsDisabledBySystemRevocation: Bool = false,
        budgetAlertsEnabled: Bool = false,
        reminderHour: Int = AppNotificationPreferences.defaultReminderHour,
        reminderMinute: Int = AppNotificationPreferences.defaultReminderMinute,
        customNotificationRecurrence: CustomNotificationRecurrence = .daily,
        oneTimeNotificationDate: Date? = nil,
        recurringNotificationStartDate: Date? = nil,
        recurringNotificationEndDate: Date? = nil,
        customRangeStartDate: Date? = nil,
        customRangeEndDate: Date? = nil
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationsDisabledBySystemRevocation = notificationsDisabledBySystemRevocation
        self.budgetAlertsEnabled = budgetAlertsEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.customNotificationRecurrence = customNotificationRecurrence
        self.oneTimeNotificationDate = oneTimeNotificationDate
        self.recurringNotificationStartDate = recurringNotificationStartDate
        self.recurringNotificationEndDate = recurringNotificationEndDate
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
        static let customNotificationRecurrence = "notification.preferences.customNotificationRecurrence"
        static let oneTimeNotificationDate = "notification.preferences.oneTimeNotificationDate"
        static let recurringNotificationStartDate = "notification.preferences.recurringNotificationStartDate"
        static let recurringNotificationEndDate = "notification.preferences.recurringNotificationEndDate"
        static let customRangeStartDate = "notification.preferences.customRangeStartDate"
        static let customRangeEndDate = "notification.preferences.customRangeEndDate"
    }

    static func load(from defaults: UserDefaults = .standard) -> AppNotificationPreferences {
        let storedHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? defaultReminderHour
        let storedMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? defaultReminderMinute
        let storedCustomRangeStartDate = defaults.object(forKey: Keys.customRangeStartDate) as? Date
        let storedCustomRangeEndDate = defaults.object(forKey: Keys.customRangeEndDate) as? Date
        let recurrenceRawValue = defaults.string(forKey: Keys.customNotificationRecurrence)
        let recurrence = CustomNotificationRecurrence(rawValue: recurrenceRawValue ?? "")
            ?? (storedCustomRangeStartDate != nil && storedCustomRangeEndDate != nil ? .customRange : .daily)

        return AppNotificationPreferences(
            notificationsEnabled: defaults.bool(forKey: Keys.notificationsEnabled),
            notificationsDisabledBySystemRevocation: defaults.bool(forKey: Keys.notificationsDisabledBySystemRevocation),
            budgetAlertsEnabled: defaults.bool(forKey: Keys.budgetAlertsEnabled),
            reminderHour: min(max(storedHour, 0), 23),
            reminderMinute: min(max(storedMinute, 0), 59),
            customNotificationRecurrence: recurrence,
            oneTimeNotificationDate: defaults.object(forKey: Keys.oneTimeNotificationDate) as? Date,
            recurringNotificationStartDate: defaults.object(forKey: Keys.recurringNotificationStartDate) as? Date,
            recurringNotificationEndDate: defaults.object(forKey: Keys.recurringNotificationEndDate) as? Date,
            customRangeStartDate: storedCustomRangeStartDate,
            customRangeEndDate: storedCustomRangeEndDate
        )
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        defaults.set(notificationsDisabledBySystemRevocation, forKey: Keys.notificationsDisabledBySystemRevocation)
        defaults.set(budgetAlertsEnabled, forKey: Keys.budgetAlertsEnabled)
        defaults.set(reminderHour, forKey: Keys.reminderHour)
        defaults.set(reminderMinute, forKey: Keys.reminderMinute)
        defaults.set(customNotificationRecurrence.rawValue, forKey: Keys.customNotificationRecurrence)
        defaults.set(oneTimeNotificationDate, forKey: Keys.oneTimeNotificationDate)
        defaults.set(recurringNotificationStartDate, forKey: Keys.recurringNotificationStartDate)
        defaults.set(recurringNotificationEndDate, forKey: Keys.recurringNotificationEndDate)
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

        guard normalizedStart < normalizedEnd else {
            return nil
        }

        let daySpan = calendar.dateComponents([.day], from: normalizedStart, to: normalizedEnd).day ?? 0
        guard daySpan < Self.maximumCustomRangeLengthInDays else {
            return nil
        }

        return normalizedStart...normalizedEnd
    }

    var recurringDateInterval: ClosedRange<Date>? {
        guard
            let start = recurringNotificationStartDate,
            let end = recurringNotificationEndDate
        else {
            return nil
        }

        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)

        guard normalizedStart <= normalizedEnd else {
            return nil
        }

        return normalizedStart...normalizedEnd
    }

    var normalizedRecurringStartDate: Date? {
        guard let recurringNotificationStartDate else {
            return nil
        }

        return Calendar.current.startOfDay(for: recurringNotificationStartDate)
    }

    var normalizedOneTimeNotificationDate: Date? {
        guard let oneTimeNotificationDate else {
            return nil
        }

        return Calendar.current.startOfDay(for: oneTimeNotificationDate)
    }

    mutating func setCustomRange(from startDate: Date, to endDate: Date, calendar: Calendar = .current) {
        customRangeStartDate = calendar.startOfDay(for: startDate)
        customRangeEndDate = calendar.startOfDay(for: endDate)
    }

    mutating func clearCustomRange() {
        customRangeStartDate = nil
        customRangeEndDate = nil
    }

    mutating func setOneTimeNotificationDate(_ date: Date, calendar: Calendar = .current) {
        oneTimeNotificationDate = calendar.startOfDay(for: date)
    }

    mutating func setRecurringStartDate(_ date: Date, calendar: Calendar = .current) {
        recurringNotificationStartDate = calendar.startOfDay(for: date)
    }

    mutating func setRecurringEndDate(_ date: Date?, calendar: Calendar = .current) {
        recurringNotificationEndDate = date.map { calendar.startOfDay(for: $0) }
    }

    var reminderScheduleSummary: String {
        switch customNotificationRecurrence {
        case .once:
            guard let oneTimeNotificationDate else {
                return "One-time reminder"
            }

            return "One-time reminder on \(formattedDate(oneTimeNotificationDate)) at \(formattedReminderTime)"
        case .daily:
            if let recurringNotificationEndDate {
                return "Daily reminder until \(formattedDate(recurringNotificationEndDate))"
            }

            return "Daily reminder at \(formattedReminderTime)"
        case .weekly:
            guard let recurringNotificationStartDate else {
                return "Weekly reminder"
            }

            let weekday = recurringNotificationStartDate.formatted(.dateTime.weekday(.wide))
            return "Weekly reminder every \(weekday)"
        case .monthly:
            guard let recurringNotificationStartDate else {
                return "Monthly reminder"
            }

            let day = Calendar.current.component(.day, from: recurringNotificationStartDate)
            return "Monthly reminder on the \(ordinalString(for: day))"
        case .customRange:
            guard let customRangeEndDate else {
                return "Custom range reminder"
            }

            return "Custom range until \(formattedDate(customRangeEndDate))"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private func ordinalString(for number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
