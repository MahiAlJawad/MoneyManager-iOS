//
//  NotificationManager.swift
//  MoneyManager-iOS
//
//  Created by Codex on 25/4/26.
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
        static let dailyReminder = "moneymanager.notification.dailyReminder"
        static let budgetAlertMidMonth = "moneymanager.notification.budgetAlertMidMonth"
        static let budgetAlertLateMonth = "moneymanager.notification.budgetAlertLateMonth"
        static let customRangePrefix = "moneymanager.notification.customRange."

        static let all = [
            dailyReminder,
            budgetAlertMidMonth,
            budgetAlertLateMonth
        ]

        static func customRange(for date: Date, calendar: Calendar = .current) -> String {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let year = components.year ?? 0
            let month = components.month ?? 0
            let day = components.day ?? 0
            return "\(customRangePrefix)\(year)-\(month)-\(day)"
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
        await removeCustomRangeRequests()

        guard preferences.notificationsEnabled else {
            return
        }

        await scheduleDailyReminder(using: preferences)
        await scheduleCustomRangeReminders(using: preferences)

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

    private func scheduleDailyReminder(using preferences: AppNotificationPreferences) async {
        let content = UNMutableNotificationContent()
        content.title = "Log today's transactions"
        content.body = "Take a moment to record spending and income so your balances stay accurate."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: preferences.reminderComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: RequestIdentifier.dailyReminder,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
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

    private func scheduleCustomRangeReminders(using preferences: AppNotificationPreferences) async {
        guard let range = preferences.customRangeDateInterval else {
            return
        }

        let calendar = Calendar.current
        let now = Date()

        for date in dates(in: range, calendar: calendar) {
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = preferences.reminderHour
            components.minute = preferences.reminderMinute

            guard let scheduledDate = calendar.date(from: components), scheduledDate >= now else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "Log today's transactions"
            content.body = "Take a moment to record spending and income so your balances stay accurate."
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: RequestIdentifier.customRange(for: date, calendar: calendar),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )

            try? await center.add(request)
        }
    }

    private func removeCustomRangeRequests() async {
        let identifiers = await customRangeRequestIdentifiers()
        guard !identifiers.isEmpty else {
            return
        }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func customRangeRequestIdentifiers() async -> [String] {
        let pendingIdentifiers: [String] = await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            center.getPendingNotificationRequests { requests in
                let ids = requests
                    .map(\.identifier)
                    .filter { $0.hasPrefix(RequestIdentifier.customRangePrefix) }
                continuation.resume(returning: ids)
            }
        }

        let deliveredIdentifiers: [String] = await withCheckedContinuation { (continuation: CheckedContinuation<[String], Never>) in
            center.getDeliveredNotifications { notifications in
                let ids = notifications
                    .map(\.request.identifier)
                    .filter { $0.hasPrefix(RequestIdentifier.customRangePrefix) }
                continuation.resume(returning: ids)
            }
        }

        return Array(Set(pendingIdentifiers + deliveredIdentifiers))
    }

    private func dates(in range: ClosedRange<Date>, calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var currentDate = range.lowerBound

        while currentDate <= range.upperBound {
            dates.append(currentDate)

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }

            currentDate = nextDate
        }

        return dates
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
