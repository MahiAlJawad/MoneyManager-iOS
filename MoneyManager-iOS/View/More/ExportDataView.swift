//
//  ExportDataView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 20/04/25.
//

import SwiftUI

private enum ExportScopeOption: String, CaseIterable, Identifiable {
    case monthly
    case allHistory
    case custom

    var id: String { rawValue }
}

struct ExportDataView: View {
    private static let defaultCustomRangeDays = 30

    @State private var selectedScope: ExportScopeOption = .monthly
    @State private var selectedFormat: ExportFormatOption = .csv
    @State private var isExportFormatSheetPresented = false
    @State private var endDate = Date()
    @State private var startDate = Calendar.current.date(
        byAdding: .day,
        value: -(ExportDataView.defaultCustomRangeDays - 1),
        to: Date()
    ) ?? Date()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                scopeSection
                customRangePreview
                exportButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isExportFormatSheetPresented) {
            ExportFormatSheetView(
                selectedFormat: $selectedFormat,
                isPresented: $isExportFormatSheetPresented
            )
            .presentationDetents([.height(410)])
            .presentationDragIndicator(.hidden)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {

                Text("Export clean CSV files for monthly reports, full history backups, or a custom period.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    heroPill(title: "CSV ready", subtitle: "Spreadsheet friendly")
                    heroPill(title: "Quick export", subtitle: "2 taps to save")
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }

    private var scopeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select export scope")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text("Choose one option before generating the CSV file.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                scopeCard(
                    scope: .monthly,
                    badgeText: "31",
                    badgeColor: Color(hex: "#1F8F63"),
                    title: "Monthly transaction",
                    subtitle: "Export entries from the current month only."
                )

                scopeCard(
                    scope: .allHistory,
                    badgeText: "∞",
                    badgeColor: Color(hex: "#3C7CFF"),
                    title: "Entire transaction history",
                    subtitle: "Include all income, expenses, and transfers."
                )

                VStack(spacing: 0) {
                    scopeCard(
                        scope: .custom,
                        badgeText: "□",
                        badgeColor: Color(hex: "#F5A623"),
                        title: "Custom date range",
                        subtitle: "Pick start and end dates for a tailored report."
                    )

                    if selectedScope == .custom {
                        customDateSelection
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(selectedScope == .custom ? Color(hex: "#F5A623") : cardStrokeColor, lineWidth: selectedScope == .custom ? 1.5 : 1)
                }
                .shadow(color: shadowColor, radius: 18, y: 8)
            }
        }
        .animation(.snappy(duration: 0.24), value: selectedScope)
    }

    private var customDateSelection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                dateField(
                    title: "Start date",
                    date: $startDate,
                    range: ...endDate
                )

                dateField(
                    title: "End date",
                    date: $endDate,
                    range: startDate...Date.distantFuture
                )
            }

            Label("The CSV will include transactions between these two dates.", systemImage: "calendar.badge.clock")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var customRangePreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom range preview")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("\(formattedDate(startDate))  -  \(formattedDate(endDate))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.78))
        )
    }

    private var exportButton: some View {
        Button {
            selectedFormat = .csv
            isExportFormatSheetPresented = true
        } label: {
            HStack(spacing: 1) {
                Spacer()

                Text("Export")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Image(systemName: "arrow.right")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#1F8F63"), Color(hex: "#26B86A")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color(hex: "#1F8F63").opacity(0.24), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.top, 5)
    }

    private func heroPill(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func scopeCard(
        scope: ExportScopeOption,
        badgeText: String,
        badgeColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        Button {
            selectedScope = scope
        } label: {
            HStack(spacing: 10) {
                Text(badgeText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(badgeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                selectionIndicator(
                    isSelected: selectedScope == scope,
                    tint: scope == .custom ? Color(hex: "#F5A623") : badgeColor
                )
            }
            .padding(15)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        selectedScope == scope ? badgeColor : cardStrokeColor,
                        lineWidth: selectedScope == scope ? 1.5 : 1
                    )
            }
            .shadow(color: shadowColor, radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func selectionIndicator(isSelected: Bool, tint: Color) -> some View {
        ZStack {
            Circle()
                .stroke(isSelected ? tint : Color(uiColor: .quaternaryLabel), lineWidth: 2)
                .frame(width: 28, height: 28)

            if isSelected {
                Circle()
                    .fill(tint)
                    .frame(width: 14, height: 14)
            }
        }
    }

    private func dateField(title: String, date: Binding<Date>, range: PartialRangeThrough<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            DatePicker(title, selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func dateField(title: String, date: Binding<Date>, range: ClosedRange<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            DatePicker(title, selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var cardBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    private var cardStrokeColor: Color {
        Color(uiColor: .separator).opacity(0.18)
    }

    private var shadowColor: Color {
        Color.black.opacity(0.05)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ExportDataView()
    }
}
