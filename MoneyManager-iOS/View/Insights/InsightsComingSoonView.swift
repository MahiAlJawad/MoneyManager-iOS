//
//  InsightsComingSoonView.swift
//  MoneyManager-iOS
//

import SwiftUI

struct InsightsComingSoonView: View {
    var body: some View {
        ContentUnavailableView(
            "Coming Soon",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Insights will be available in a future update.")
        )
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Insights")
    }
}
