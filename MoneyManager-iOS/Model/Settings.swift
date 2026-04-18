//
//  Settings.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import Foundation

// TODO: Make enums instead of this @Shakib
struct Settings: Identifiable {
    var id = UUID()
    var image: String
    var title: String
}

extension Settings {
    static var allSettingsData: [Settings] = [
        Settings(image: "book.and.wrench", title: "General"),
        Settings(image: "chart.line.text.clipboard.fill", title: "Dashboard"),
        Settings(image: "dollarsign.bank.building.fill", title: "Accounts"),
        Settings(image: "dollarsign.square.fill", title: "Currency"),
        Settings(image: "filemenu.and.cursorarrow", title: "Categories"),
        Settings(image: "person.badge.key.fill", title: "Personal data & Privacy"),
        Settings(image: "lock.square", title: "Security")
    ]
}
