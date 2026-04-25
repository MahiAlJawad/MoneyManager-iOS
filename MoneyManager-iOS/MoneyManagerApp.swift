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
    init() {
        NotificationManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
        }.modelContainer(for: [Account.self])
    }
}
