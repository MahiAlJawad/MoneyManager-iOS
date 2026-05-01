//
//  InsightsView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 30/4/26.
//

import SwiftUI

struct InsightsView: View {
    enum Destination: Hashable {
        case detailMoneyFlow
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                MoneyFlowViewCard()
                comingSoonSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Insights")
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .detailMoneyFlow:
                DetailMoneyFlowView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Insights")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color(uiColor: .label))
            
            Text("Explore your money patterns")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var comingSoonSection: some View {
        ContentUnavailableView(
            "More insights coming soon",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Detailed spending, category, and account insights will appear here.")
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
