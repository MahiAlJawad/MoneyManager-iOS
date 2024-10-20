//
//  Statistics.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 20/10/24.
//

import Foundation

struct StatisticsMenuItem: Identifiable, Hashable {
    var id = UUID()
    var image: String
    var title: String
}

extension StatisticsMenuItem {
    static var statisticsMenuItem: [StatisticsMenuItem] = [
        StatisticsMenuItem(image: "person.text.rectangle.fill", title: "Spending")
    ]
}
