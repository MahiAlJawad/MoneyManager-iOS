//  StatisticsView.swift - MoneyManager-iOS
//  Copyright © 2024 COMPANYNAME. All rights reserved.

import Charts
import SwiftUI

// TODO: Might be fetched from Locale
enum Month: String, CaseIterable {
    case jan = "January"
    case feb = "February"
    case mar = "March"
    case apr = "April"
    case may = "May"
    case jun = "June"
    case jul = "July"
    case aug = "August"
    case sep = "September"
    case oct = "October"
    case nov = "November"
    case dec = "December"
}

// TODO: Will be changed according to global model
struct ExpenseData: Identifiable {
    let id = UUID()
    let month: Month
    let expense: Double
}

struct StatisticsView: View {
    private let expenseData: [ExpenseData]
    
    init() {
        // TODO: Demo data
        expenseData = Month.allCases.reduce(into: [ExpenseData]()) {
            $0.append(.init(month: $1, expense: Double.random(in: 1...100)))
        }
    }

    var body: some View {
        VStack {
            Chart {
                ForEach(expenseData) {
                    BarMark(
                        x: .value("Month", $0.month.rawValue),
                        y: .value("Expense", $0.expense)
                    )
                }
            }
            Spacer()
        }
    }
}

#Preview {
    StatisticsView()
}
