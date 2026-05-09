//
//  AppearanceView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 09/05/26.
//

import SwiftUI

struct AppearanceView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceMode.userDefaultsKey) private var appearanceModeRawValue = AppearanceMode.system.rawValue

    private var selectedAppearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("APPEARANCE")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    appearanceOptionCard(for: .light)
                    appearanceOptionCard(for: .dark)
                    appearanceOptionCard(for: .system)
                }
                
                Text("Select a theme for your app or match your device's system settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)

                Text("MODE")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                modeSelectionCard

                Text("Overrides your iPhone system appearance.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var cardBackgroundColor: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    private var modeSelectionCard: some View {
        VStack(spacing: 0) {
            modeRow(for: .light)
            divider
            modeRow(for: .dark)
            divider
            modeRow(for: .system)
        }
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var divider: some View {
        Divider()
            .padding(.leading, 46)
    }

    private func modeRow(for mode: AppearanceMode) -> some View {
        Button {
            appearanceModeRawValue = mode.rawValue
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.modeRowIcon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(mode == .light ? Color.orange : .secondary)
                    .frame(width: 24, height: 24)

                Text(mode.modeRowTitle)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                if selectedAppearanceMode == mode {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: "#1F8F63"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func appearanceOptionCard(for mode: AppearanceMode) -> some View {
        Button {
            appearanceModeRawValue = mode.rawValue
        } label: {
            VStack(spacing: 10) {
                previewCard(for: mode)

                Text(mode.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Image(systemName: selectedAppearanceMode == mode ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(selectedAppearanceMode == mode ? Color(hex: "#1F8F63") : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func previewCard(for mode: AppearanceMode) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(previewCardFill(for: mode))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        selectedAppearanceMode == mode ? Color(hex: "#1D74E7") : Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.12),
                        lineWidth: selectedAppearanceMode == mode ? 2.4 : 1
                    )
            )
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(mode == .dark ? 0.40 : 0.10))
                        .frame(width: 20, height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(mode == .dark ? 0.28 : 0.08))
                        .frame(width: 54, height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(mode == .dark ? 0.24 : 0.06))
                        .frame(width: 64, height: 7)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#1D74E7").opacity(mode == .dark ? 0.80 : 0.15))
                        .frame(width: 62, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(mode == .dark ? 0.22 : 0.06))
                        .frame(width: 44, height: 7)
                }
                .padding(12)
            }
            .frame(height: 122)
    }

    private func previewCardFill(for mode: AppearanceMode) -> LinearGradient {
        switch mode {
        case .light:
            return LinearGradient(
                colors: [Color.white, Color(hex: "#F4F7FC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.black, Color(hex: "#0B1220")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .system:
            return LinearGradient(
                colors: [Color.black, Color.black, Color.white, Color(hex: "#F4F7FC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceView()
    }
}
