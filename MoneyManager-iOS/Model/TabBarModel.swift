//
//  TabBarModel.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 4/10/24.
//

import Foundation

struct TabBarModel {
    enum Item: CaseIterable {
        case dashboard
        case accounts
        case statistics
        case more
        
        var title: String {
            switch self {
            case .dashboard:    return "Dashboard"
            case .accounts:     return "Accounts"
            case .statistics:   return "Statistics"
            case .more:         return "More"
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard:  return "dollarsign.bank.building.fill"
            case .accounts:   return "note.text"
            case .statistics: return "chart.bar.xaxis"
            case .more:       return "ellipsis.circle.fill"
            }
        }
    }
}
