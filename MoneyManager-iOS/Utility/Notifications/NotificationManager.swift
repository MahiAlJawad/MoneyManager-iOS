//
//  NotificationManager.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 25/4/26.
//

import Foundation
import UIKit
import UserNotifications

enum AppNotificationAuthorizationStatus: Equatable {
    case notDetermined
    case denied
    case authorized
}

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private enum RequestIdentifier {
        static let onceReminder = "moneymanager.notification.onceReminder"
        static let recurringReminder = "moneymanager.notification.recurringReminder"
        static let generatedReminderPrefix = "moneymanager.notification.generated."
        static let budgetAlertMidMonth = "moneymanager.notification.budgetAlertMidMonth"
        static let budgetAlertLateMonth = "moneymanager.notification.budgetAlertLateMonth"

        static let all = [
            onceReminder,
            recurringReminder,
            budgetAlertMidMonth,
            budgetAlertLateMonth
        ]

        static func generated(for date: Date, suffix: String, calendar: Calendar = .current) -> String {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let year = components.year ?? 0
            let month = components.month ?? 0
            let day = components.day ?? 0
            return "\(generatedReminderPrefix)\(suffix).\(year)-\(month)-\(day)"
        }
    }

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func configure() {
        center.delegate = self
    }

    func authorizationStatus() async -> AppNotificationAuthorizationStatus {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func syncNotifications(using preferences: AppNotificationPreferences) async {
        center.removePendingNotificationRequests(withIdentifiers: RequestIdentifier.all)
        center.removeDeliveredNotifications(withIdentifiers: RequestIdentifier.all)
        await removeGeneratedReminderRequests()

        guard preferences.notificationsEnabled else {
            return
        }

        await scheduleReminder(using: preferences)

        guard preferences.budgetAlertsEnabled else {
            return
        }

        await scheduleBudgetAlert(day: 15, identifier: RequestIdentifier.budgetAlertMidMonth, using: preferences)
        await scheduleBudgetAlert(day: 25, identifier: RequestIdentifier.budgetAlertLateMonth, using: preferences)
    }

    func openNotificationSystemSettings() {
        let settingsURLString: String

        if #available(iOS 16.0, *) {
            settingsURLString = UIApplication.openNotificationSettingsURLString
        } else {
            settingsURLString = UIApplication.openSettingsURLString
        }

        guard let url = URL(string: settingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url)
    }

    private func scheduleReminder(using preferences: AppNotificationPreferences) async {
        switch preferences.customNotificationRecurrence {
        case .once:
            await scheduleOnceReminder(using: preferences)
        case .daily:
            await scheduleDailyReminder(using: preferences)
        case .weekly:
            await scheduleWeeklyReminder(using: preferences)
        case .monthly:
            await scheduleMonthlyReminder(using: preferences)
        case .customRange:
            await scheduleCustomRangeReminders(using: preferences)
        }
    }

    private func scheduleBudgetAlert(
        day: Int,
        identifier: String,
        using preferences: AppNotificationPreferences
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "Budget check-in"
        content.body = "Review this month's spending and make any adjustments before the month slips by."
        content.sound = .default

        var components = preferences.reminderComponents
        components.day = day

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        try? await center.add(request)
    }

    private func scheduleOnceReminder(using preferences: AppNotificationPreferences) async {
        let calendar = Calendar.current
        let now = Date()

        guard let selectedDate = preferences.normalizedOneTimeNotificationDate else {
            return
        }

        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = preferences.reminderHour
        components.minute = preferences.reminderMinute

        guard let scheduledDate = calendar.date(from: components), scheduledDate >= now else {
            return
        }

        let request = UNNotificationRequest(
            identifier: RequestIdentifier.onceReminder,
            content: reminderContent(),
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )

        try? await center.add(request)
    }

    private func scheduleDailyReminder(using preferences: AppNotificationPreferences) async {
        if let range = preferences.recurringDateInterval {
            await scheduleGeneratedReminders(
                on: dates(in: range, matching: .day, calendar: .current),
                suffix: "daily",
                using: preferences
            )
            return
        }

        let request = UNNotificationRequest(
            identifier: RequestIdentifier.recurringReminder,
            content: reminderContent(),
            trigger: UNCalendarNotificationTrigger(
                dateMatching: preferences.reminderComponents,
                repeats: true
            )
        )

        try? await center.add(request)
    }

    private func scheduleWeeklyReminder(using preferences: AppNotificationPreferences) async {
        let calendar = Calendar.current

        guard let startDate = preferences.normalizedRecurringStartDate else {
            return
        }

        if let range = preferences.recurringDateInterval {
            await scheduleGeneratedReminders(
                on: dates(in: range, matching: .weekOfYear, calendar: calendar),
                suffix: "weekly",
                using: preferences
            )
            return
        }

        var components = preferences.reminderComponents
        components.weekday = calendar.component(.weekday, from: startDate)

        let request = UNNotificationRequest(
            identifier: RequestIdentifier.recurringReminder,
            content: reminderContent(),
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        try? await center.add(request)
    }

    private func scheduleMonthlyReminder(using preferences: AppNotificationPreferences) async {
        let calendar = Calendar.current

        guard let startDate = preferences.normalizedRecurringStartDate else {
            return
        }

        if let range = preferences.recurringDateInterval {
            await scheduleGeneratedReminders(
                on: monthlyDates(in: range, anchorDate: startDate, calendar: calendar),
                suffix: "monthly",
                using: preferences
            )
            return
        }

        var components = preferences.reminderComponents
        components.day = calendar.component(.day, from: startDate)

        let request = UNNotificationRequest(
            identifier: RequestIdentifier.recurringReminder,
            content: reminderContent(),
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        try? await center.add(request)
    }

    private func scheduleCustomRangeReminders(using preferences: AppNotificationPreferences) async {
        guard let range = preferences.customRangeDateInterval else {
            return
        }

        await scheduleGeneratedReminders(
            on: dates(in: range, matching: .day, calendar: .current),
            suffix: "customRange",
            using: preferences
        )
    }

    private func scheduleGeneratedReminders(
        on dates: [Date],
        suffix: String,
        using preferences: AppNotificationPreferences
    ) async {
        let calendar = Calendar.current
        let now = Date()

        for date in dates {
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = preferences.reminderHour
            components.minute = preferences.reminderMinute

            guard let scheduledDate = calendar.date(from: components), scheduledDate >= now else {
                continue
            }

            let request = UNNotificationRequest(
                identifier: RequestIdentifier.generated(for: date, suffix: suffix, calendar: calendar),
                content: reminderContent(),
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )

            try? await center.add(request)
        }
    }

    private func removeGeneratedReminderRequests() async {
        let identifiers = await generatedReminderRequestIdentifiers()
        guard !identifiers.isEmpty else {
            return
        }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func generatedReminderRequestIdentifiers() async -> [String] {
        let pendingIdentifiers: [String] = await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            center.getPendingNotificationRequests { requests in
                let ids = requests
                    .map(\.identifier)
                    .filter { $0.hasPrefix(RequestIdentifier.generatedReminderPrefix) }
                continuation.resume(returning: ids)
            }
        }

        let deliveredIdentifiers: [String] = await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            center.getDeliveredNotifications { notifications in
                let ids = notifications
                    .map(\.request.identifier)
                    .filter { $0.hasPrefix(RequestIdentifier.generatedReminderPrefix) }
                continuation.resume(returning: ids)
            }
        }

        return Array(Set(pendingIdentifiers + deliveredIdentifiers))
    }

    private func dates(in range: ClosedRange<Date>, matching component: Calendar.Component, calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var currentDate = range.lowerBound

        while currentDate <= range.upperBound {
            dates.append(currentDate)

            let nextDate: Date?

            switch component {
            case .day:
                nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
            case .weekOfYear:
                nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
            case .month:
                nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate)
            default:
                nextDate = nil
            }

            guard let nextDate else {
                break
            }

            currentDate = nextDate
        }

        return dates
    }

    private func monthlyDates(in range: ClosedRange<Date>, anchorDate: Date, calendar: Calendar) -> [Date] {
        let anchorDay = calendar.component(.day, from: anchorDate)
        var dates: [Date] = []
        var currentMonth = calendar.dateInterval(of: .month, for: range.lowerBound)?.start ?? range.lowerBound

        while currentMonth <= range.upperBound {
            var components = calendar.dateComponents([.year, .month], from: currentMonth)
            components.day = anchorDay

            if let candidate = calendar.date(from: components), range.contains(candidate) {
                dates.append(candidate)
            }

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else {
                break
            }

            currentMonth = nextMonth
        }

        return dates
    }

    private func reminderContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Log today's transactions"
        content.body = "Take a moment to record spending and income so your balances stay accurate."
        content.sound = .default
        return content
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
