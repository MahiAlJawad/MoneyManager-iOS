//
//  MoneyManager_iOSApp.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 1/10/24.
//

import SwiftUI
import SwiftData

@main
struct MoneyManager_iOSApp: App {
    @AppStorage(AppearanceMode.userDefaultsKey) private var appearanceModeRawValue = AppearanceMode.system.rawValue

    init() {
        NotificationManager.shared.configure()
    }

    private var selectedAppearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(selectedAppearanceMode.colorScheme)
        }.modelContainer(for: [Account.self])
    }
}
