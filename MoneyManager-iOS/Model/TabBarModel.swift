//
//  TabBarModel.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 4/10/24.
//

import Foundation

struct TabBarModel {
    enum Item {
        case home
        case transactions
        case insights
        case settings
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .transactions:
                return "Transactions"
            case .insights:
                return "Insights"
            case .settings:
                return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .home:
                return "house.fill"
            case .transactions:
                return "list.bullet.rectangle.fill"
            case .insights:
                return "chart.line.uptrend.xyaxis"
            case .settings:
                return "gearshape.fill"
            }
        }
    }
}
