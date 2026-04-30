//
//  ExportFormatSheetView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 30/04/26.
//

import SwiftUI

struct ExportFormatSheetView: View {
    @Binding var selectedFormat: ExportFormatOption
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(uiColor: .systemGray3))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            VStack(spacing: 6) {
                Text("Export Format")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Choose a format for your exported data.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 14)

            VStack(spacing: 10) {
                ExportFormatCardView(format: .csv, selectedFormat: $selectedFormat)
                ExportFormatCardView(format: .pdf, selectedFormat: $selectedFormat)
            }
            .padding(.top, 18)

            Button(action: {}) {
                Text(selectedFormat.actionTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .contentTransition(.opacity)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(selectedFormat.tintColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
            .animation(.snappy(duration: 0.22), value: selectedFormat)

            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct ExportFormatCardView: View {
    let format: ExportFormatOption
    @Binding var selectedFormat: ExportFormatOption

    private var isSelected: Bool {
        selectedFormat == format
    }

    var body: some View {
        Button {
            selectedFormat = format
        } label: {
            HStack(spacing: 14) {
                Image(systemName: format.iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(format.tintColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(format.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(format.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ExportFormatSelectionIndicatorView(isSelected: isSelected, tint: format.tintColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSelected ? format.tintColor : Color(uiColor: .separator).opacity(0.18),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.22), value: isSelected)
    }
}

private struct ExportFormatSelectionIndicatorView: View {
    let isSelected: Bool
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? tint : Color(uiColor: .quaternaryLabel), lineWidth: 1.5)
                .frame(width: 28, height: 28)

            Circle()
                .fill(tint)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundColor(.white)
                }
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : 0.75)
        }
        .animation(.snappy(duration: 0.22), value: isSelected)
    }
}

#Preview {
    ExportFormatSheetView(
        selectedFormat: .constant(.csv),
        isPresented: .constant(true)
    )
}
