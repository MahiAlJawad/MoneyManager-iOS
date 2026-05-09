//
//  Settings.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import Foundation
import SwiftUI

// TODO: Make enums instead of this @Shakib
struct Settings: Identifiable, Hashable {
    var id = UUID()
    var image: String
    var title: String
}

extension Settings {
    static var allSettingsData: [Settings] = [
        Settings(image: "book.and.wrench", title: "General"),
        Settings(image: "chart.line.text.clipboard.fill", title: "Home"),
        Settings(image: "dollarsign.bank.building.fill", title: "Accounts"),
        Settings(image: "dollarsign.square.fill", title: "Currency"),
        Settings(image: "filemenu.and.cursorarrow", title: "Categories"),
        Settings(image: "person.badge.key.fill", title: "Personal data & Privacy"),
        Settings(image: "lock.square", title: "Security")
    ]
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    static let userDefaultsKey = "appearanceMode"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }

    var description: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    var modeRowTitle: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "Use System Settings"
        }
    }

    var modeRowIcon: String {
        switch self {
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        case .system:
            return "circle.lefthalf.filled"
        }
    }
}
