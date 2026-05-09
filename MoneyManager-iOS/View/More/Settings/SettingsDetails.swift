//
//  SettingsDetails.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import SwiftUI

struct SettingsDetails: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SettingsTabView.Router.self) private var router

    @State private var notificationPreferences = AppNotificationPreferences.load()
    @State private var authorizationStatus: AppNotificationAuthorizationStatus = .notDetermined
    @State private var isReminderTimePickerPresented = false
    @State private var showNotificationSettingsAlert = false
    @State private var notificationAlertTitle = "Notifications are unavailable"
    @State private var permissionAlertMessage = ""
    @State private var shouldOfferNotificationSettingsLink = false
    @State private var debugTapCount: Int = 0
    @State private var isDebugDrawerPresented = false
    
    private var cardBackgroundColor: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }
    
    private var cardCornerRadius: CGFloat { 16 }
    
    private var primaryAccentColor: Color {
        colorScheme == .dark ? Color(hex: "#A9EBCF") : Color(hex: "#1F8F63")
    }
    
    private var primaryAccentBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#163D34") : Color(hex: "#E8F3EB")
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                profileHeader

                settingsButton(
                    icon: "paintbrush.fill",
                    iconForegroundColor: primaryAccentColor,
                    iconBackgroundColor: primaryAccentBackgroundColor,
                    title: "Appearance"
                ) {
                    router.navigateForFirstNavigation(to: .appearanceView)
                }

                settingsButton(
                    icon: "dollarsign.circle.fill",
                    iconForegroundColor: primaryAccentColor,
                    iconBackgroundColor: primaryAccentBackgroundColor,
                    title: "Currency",
                    trailingText: "BDT ৳"
                ) {
                    router.navigateForFirstNavigation(to: .currencyView)
                }

                settingsButton(
                    icon: "bell.fill",
                    iconForegroundColor: primaryAccentColor,
                    iconBackgroundColor: primaryAccentBackgroundColor,
                    title: "System Notifications",
                    subtitle: systemNotificationsStatusText,
                    trailingText: systemNotificationsTrailingText
                ) {
                    Task {
                        await handleSystemNotificationsTap()
                    }
                }

                settingsToggle(
                    icon: "bell.badge.fill",
                    iconForegroundColor: primaryAccentColor,
                    iconBackgroundColor: primaryAccentBackgroundColor,
                    title: "Daily Reminders",
                    subtitle: dailyRemindersStatusText,
                    isOn: notificationsToggleBinding,
                    isDisabled: !isSystemNotificationsAuthorized,
                    onTapWhenDisabled: {
                        Task {
                            await handleNotificationToggleChange(true)
                        }
                    }
                )

                if isSystemNotificationsAuthorized {
                    settingsButton(
                        icon: "slider.horizontal.3",
                        iconForegroundColor: primaryAccentColor,
                        iconBackgroundColor: primaryAccentBackgroundColor,
                        title: "Custom Notification",
                        subtitle: "Fine-tune reminder messaging and schedule"
                    ) {
                        router.navigateForFirstNavigation(to: .customNotificationView)
                    }
                }

                settingsToggle(
                    icon: "exclamationmark.triangle.fill",
                    iconForegroundColor: Color.orange,
                    iconBackgroundColor: Color.orange.opacity(colorScheme == .dark ? 0.22 : 0.14),
                    title: "Budget alerts",
                    subtitle: budgetAlertStatusText,
                    isOn: budgetAlertsBinding,
                    isDisabled: !canConfigureReminderSettings
                )

                reminderScheduleCard

                settingsButton(
                    icon: "square.and.arrow.up.fill",
                    iconForegroundColor: Color.blue,
                    iconBackgroundColor: Color.blue.opacity(colorScheme == .dark ? 0.22 : 0.14),
                    title: "Export data",
                    trailingText: "CSV · PDF"
                ) {
                    router.navigateForFirstNavigation(to: .exportDataView)
                }

                settingsButton(
                    icon: "questionmark.circle.fill",
                    iconForegroundColor: Color.green,
                    iconBackgroundColor: Color.green.opacity(colorScheme == .dark ? 0.22 : 0.14),
                    title: "Help & FAQ"
                ) {
                    router.navigateForFirstNavigation(to: .helpView)
                }

                settingsButton(
                    icon: "message.fill",
                    iconForegroundColor: Color.red,
                    iconBackgroundColor: Color.red.opacity(colorScheme == .dark ? 0.24 : 0.14),
                    title: "Send feedback"
                ) {
                    router.navigateForFirstNavigation(to: .sendFeedbackView)
                }

                Button(action: {
                    router.navigateForFirstNavigation(to: .signOutView)
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(colorScheme == .dark ? 0.24 : 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Text("Sign out")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                }

                Text("MoneyManager 1.0 · Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .onTapGesture {
                        handleVersionTap()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Settings")
        .task {
            await refreshNotificationState()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            Task {
                await refreshNotificationState()
            }
        }
        .alert(notificationAlertTitle, isPresented: $showNotificationSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            if shouldOfferNotificationSettingsLink {
                Button("Open Settings") {
                    NotificationManager.shared.openNotificationSystemSettings()
                }
            }
        } message: {
            Text(permissionAlertMessage)
        }
        .sheet(isPresented: $isDebugDrawerPresented) {
            debugDrawer
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var profileHeader: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                        ? [Color(hex: "#0F5D4F"), Color(hex: "#136959"), Color(hex: "#1B7A67")]
                        : [Color(hex: "#156C60"), Color(hex: "#1A7565"), Color(hex: "#2D8571")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 62, height: 62)
                    .overlay(
                        Text("AR")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Arif Rahman")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(verbatim: "arif@email.com")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                }

                Spacer()

                Text("Pro Plan")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(20)
        }
        .frame(height: 160)
    }
    
    private func settingsButton(
        icon: String,
        iconForegroundColor: Color,
        iconBackgroundColor: Color,
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundColor(.primary)
                            .font(.body)
                            .fontWeight(.medium)

                        if let subtitle {
                            Text(subtitle)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                } icon: {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconForegroundColor)
                        .frame(width: 34, height: 34)
                        .background(iconBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Spacer()

                if let trailingText {
                    Text(trailingText)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
    
    private func settingsToggle(
        icon: String,
        iconForegroundColor: Color,
        iconBackgroundColor: Color,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        isDisabled: Bool = false,
        onTapWhenDisabled: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(iconForegroundColor)
                .frame(width: 34, height: 34)
                .background(iconBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.body)
                    .fontWeight(.medium)

                if let subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(primaryAccentColor)
                .disabled(isDisabled)
        }
        .padding()
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .opacity(isDisabled ? 0.6 : 1)
        .contentShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .onTapGesture {
            guard isDisabled else {
                return
            }

            onTapWhenDisabled?()
        }
    }

    private var reminderScheduleCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reminder Time")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(
                        canConfigureReminderSettings
                        ? "A gentle nudge to record your spending and income."
                        : "Available after daily reminders are enabled"
                    )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    withAnimation(.snappy(duration: 0.22)) {
                        isReminderTimePickerPresented.toggle()
                    }
                }) {
                    Text(notificationPreferences.formattedReminderTime)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryAccentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(primaryAccentBackgroundColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canConfigureReminderSettings)
            }

            if isReminderTimePickerPresented && canConfigureReminderSettings {
                DatePicker(
                    "Reminder time",
                    selection: reminderDateBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }

            if notificationPreferences.budgetAlertsEnabled {
                Label("Budget alerts arrive twice a month at the same time.", systemImage: "calendar.badge.clock")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .opacity(canConfigureReminderSettings ? 1 : 0.6)
    }

    private var debugDrawer: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("Debug Tools")
                    .font(.headline)
                    .padding(.top, 8)

                settingsButton(
                    icon: "tray.and.arrow.down.fill",
                    iconForegroundColor: primaryAccentColor,
                    iconBackgroundColor: primaryAccentBackgroundColor,
                    title: "Seed Test Data"
                ) {
                    TestDataManager.shared.seedHomeUITestData(in: modelContext)
                    isDebugDrawerPresented = false
                }

                settingsButton(
                    icon: "trash.fill",
                    iconForegroundColor: .red,
                    iconBackgroundColor: Color.red.opacity(colorScheme == .dark ? 0.24 : 0.14),
                    title: "Clear All Data"
                ) {
                    TestDataManager.shared.clearAllData(in: modelContext)
                    isDebugDrawerPresented = false
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
    }

    private func handleVersionTap() {
        debugTapCount += 1
        
        guard debugTapCount >= 10 else {
            return
        }
        
        debugTapCount = 0
        isDebugDrawerPresented = true
    }

    private var notificationsToggleBinding: Binding<Bool> {
        Binding(
            get: { notificationPreferences.notificationsEnabled },
            set: { newValue in
                Task {
                    await handleNotificationToggleChange(newValue)
                }
            }
        )
    }

    private var budgetAlertsBinding: Binding<Bool> {
        Binding(
            get: { notificationPreferences.budgetAlertsEnabled },
            set: { newValue in
                notificationPreferences.budgetAlertsEnabled = newValue
                notificationPreferences.save()

                Task {
                    await NotificationManager.shared.syncNotifications(using: notificationPreferences)
                }
            }
        )
    }

    private var reminderDateBinding: Binding<Date> {
        Binding(
            get: { notificationPreferences.reminderDate },
            set: { newValue in
                notificationPreferences.updateReminderTime(from: newValue)
                notificationPreferences.save()

                Task {
                    await NotificationManager.shared.syncNotifications(using: notificationPreferences)
                }
            }
        )
    }

    private var isSystemNotificationsAuthorized: Bool {
        authorizationStatus == .authorized
    }

    private var canConfigureReminderSettings: Bool {
        isSystemNotificationsAuthorized && notificationPreferences.notificationsEnabled
    }

    private var systemNotificationsStatusText: String {
        switch authorizationStatus {
        case .authorized:
            return "Allowed on iPhone"
        case .notDetermined:
            return "Not set up yet"
        case .denied:
            return "Disabled in iPhone Settings"
        }
    }

    private var systemNotificationsTrailingText: String {
        switch authorizationStatus {
        case .authorized:
            return "Manage"
        case .notDetermined:
            return "Open Settings"
        case .denied:
            return "Open Settings"
        }
    }

    private var dailyRemindersStatusText: String {
        switch authorizationStatus {
        case .authorized:
            return notificationPreferences.notificationsEnabled
                ? "Daily reminder at \(notificationPreferences.formattedReminderTime)"
                : "Receive a daily reminder to log your transactions"
        case .notDetermined:
            return "Set up in iPhone Settings to enable reminders"
        case .denied:
            return "Enable in iPhone Settings first"
        }
    }

    private var budgetAlertStatusText: String {
        if !canConfigureReminderSettings {
            return "Available after daily reminders are enabled"
        }

        return notificationPreferences.budgetAlertsEnabled
            ? "Mid-month spending check-ins are scheduled"
            : "Get twice-monthly reminders to review your budget"
    }

    private func refreshNotificationState() async {
        authorizationStatus = await NotificationManager.shared.authorizationStatus()

        if authorizationStatus == .denied, notificationPreferences.notificationsEnabled {
            notificationPreferences.notificationsEnabled = false
            notificationPreferences.notificationsDisabledBySystemRevocation = true
            notificationPreferences.save()
            await NotificationManager.shared.syncNotifications(using: notificationPreferences)
            return
        }

        if authorizationStatus == .authorized, notificationPreferences.notificationsDisabledBySystemRevocation {
            notificationPreferences.notificationsEnabled = true
            notificationPreferences.notificationsDisabledBySystemRevocation = false
            notificationPreferences.save()
            await NotificationManager.shared.syncNotifications(using: notificationPreferences)
            return
        }

        if authorizationStatus != .denied, notificationPreferences.notificationsDisabledBySystemRevocation {
            notificationPreferences.notificationsDisabledBySystemRevocation = false
            notificationPreferences.save()
        }

        if authorizationStatus == .authorized, notificationPreferences.notificationsEnabled {
            notificationPreferences.notificationsDisabledBySystemRevocation = false
            notificationPreferences.save()
            await NotificationManager.shared.syncNotifications(using: notificationPreferences)
        }
    }

    private func handleSystemNotificationsTap() async {
        NotificationManager.shared.openNotificationSystemSettings()
    }

    private func handleNotificationToggleChange(_ isEnabled: Bool) async {
        if !isEnabled {
            notificationPreferences.notificationsEnabled = false
            notificationPreferences.notificationsDisabledBySystemRevocation = false
            notificationPreferences.save()
            await NotificationManager.shared.syncNotifications(using: notificationPreferences)
            return
        }

        let currentStatus = await NotificationManager.shared.authorizationStatus()
        authorizationStatus = currentStatus

        switch currentStatus {
        case .authorized:
            notificationPreferences.notificationsEnabled = true
            notificationPreferences.notificationsDisabledBySystemRevocation = false
            notificationPreferences.save()
            await NotificationManager.shared.syncNotifications(using: notificationPreferences)

        case .notDetermined, .denied:
            NotificationManager.shared.openNotificationSystemSettings()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsDetails()
    }
}
