//
//  InsightsComingSoonView.swift
//  MoneyManager-iOS
//

import SwiftUI

struct InsightsComingSoonView: View {
    private let tint = Color(hex: "#1F8F63")
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#F4FBF7"), Color(hex: "#E5F6ED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 96, height: 96)
                    .overlay {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                
                VStack(spacing: 8) {
                    Text("Insights")
                        .font(.title2.weight(.bold))
                    
                    Text("Coming soon for future updates.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
        }
        .navigationTitle("Insights")
    }
}
