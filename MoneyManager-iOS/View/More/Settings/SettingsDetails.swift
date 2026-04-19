//
//  SettingsDetails.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import SwiftUI

struct SettingsDetails: View {
    @Environment(MoreTabView.Router.self) private var router
    @State private var notificationsEnabled: Bool = true
    @State private var budgetAlertsEnabled: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                profileHeader

                settingsButton(
                    icon: "dollarsign.circle.fill",
                    iconColor: Color("AccentColor"),
                    title: "Currency",
                    trailingText: "BDT ৳"
                ) {
                    router.navigateForFirstNavigation(to: .currencyView)
                }

                settingsToggle(
                    icon: "bell.fill",
                    iconColor: Color.purple,
                    title: "Notifications",
                    isOn: $notificationsEnabled
                )

                settingsToggle(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: Color.orange,
                    title: "Budget alerts",
                    isOn: $budgetAlertsEnabled
                )

                settingsButton(
                    icon: "square.and.arrow.up.fill",
                    iconColor: Color.blue,
                    title: "Export data",
                    trailingText: "CSV · PDF"
                ) {
                    router.navigateForFirstNavigation(to: .exportDataView)
                }

                settingsButton(
                    icon: "questionmark.circle.fill",
                    iconColor: Color.green,
                    title: "Help & FAQ"
                ) {
                    router.navigateForFirstNavigation(to: .helpView)
                }

                settingsButton(
                    icon: "message.fill",
                    iconColor: Color.red.opacity(0.85),
                    title: "Send feedback"
                ) {
                    router.navigateForFirstNavigation(to: .sendFeedbackView)
                }

                Button(action: {
                    router.navigateForFirstNavigation(to: .signOutView)
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        Text("Sign out")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }

                Text("SpendWise v2.4.1 · Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Settings")
    }
    
    private var profileHeader: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.21, green: 0.34, blue: 0.93), Color(red: 0.05, green: 0.68, blue: 0.56)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 62, height: 62)
                    .overlay(
                        Text("AR")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Arif Rahman")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("arif@email.com")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Text("Pro Plan")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(20)
        }
        .frame(height: 160)
    }
    
    private func settingsButton(
        icon: String,
        iconColor: Color,
        title: String,
        trailingText: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Label {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.body)
                        .fontWeight(.medium)
                } icon: {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(iconColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                Spacer()

                if let trailingText {
                    Text(trailingText)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    private func settingsToggle(
        icon: String,
        iconColor: Color,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(title)
                .foregroundColor(.primary)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        SettingsDetails()
    }
}
