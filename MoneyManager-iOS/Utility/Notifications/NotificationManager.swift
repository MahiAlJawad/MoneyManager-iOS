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

        static let all = [
            dailyReminder,
            budgetAlertMidMonth,
            budgetAlertLateMonth
        ]
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

        guard preferences.notificationsEnabled else {
            return
        }

        await scheduleDailyReminder(using: preferences)

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

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
