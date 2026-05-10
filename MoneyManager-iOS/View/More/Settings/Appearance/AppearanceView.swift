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
    @State private var pendingSelection: AppearanceMode = .system
    @State private var applyAppearanceTask: Task<Void, Never>?

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
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pendingSelection = selectedAppearanceMode
        }
        .onDisappear {
            applyAppearanceTask?.cancel()
            applyAppearanceTask = nil
        }
        .onChange(of: appearanceModeRawValue) { _, newValue in
            let updatedMode = AppearanceMode(rawValue: newValue) ?? .system
            guard pendingSelection != updatedMode else {
                return
            }

            pendingSelection = updatedMode
        }
    }

    private func appearanceOptionCard(for mode: AppearanceMode) -> some View {
        Button {
            applySelection(mode)
        } label: {
            VStack(spacing: 10) {
                previewCard(for: mode)

                Text(mode.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Image(systemName: pendingSelection == mode ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(pendingSelection == mode ? Color(hex: "#1F8F63") : .secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
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
                        pendingSelection == mode ? Color(hex: "#1D74E7") : Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.12),
                        lineWidth: pendingSelection == mode ? 2.4 : 1
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

    private func applySelection(_ mode: AppearanceMode) {
        guard !(pendingSelection == mode && selectedAppearanceMode == mode) else {
            return
        }

        pendingSelection = mode
        applyAppearanceTask?.cancel()

        applyAppearanceTask = Task {
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                appearanceModeRawValue = mode.rawValue
                applyAppearanceTask = nil
            }
        }
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
