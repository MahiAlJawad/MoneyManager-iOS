//
//  CustomRangeNotificationView.swift
//  MoneyManager-iOS
//

import SwiftUI

struct CustomRangeNotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var displayedMonth: Date

    private let calendar: Calendar
    private let today: Date

    init() {
        let calendar = Calendar.current
        let preferences = AppNotificationPreferences.load()
        let today = calendar.startOfDay(for: Date.now)
        let defaultEndDate = calendar.date(byAdding: .day, value: 14, to: today) ?? today
        let storedStartDate = preferences.customRangeDateInterval?.lowerBound ?? today
        let storedEndDate = preferences.customRangeDateInterval?.upperBound ?? defaultEndDate
        let initialMonth = calendar.dateInterval(of: .month, for: storedStartDate)?.start ?? today

        self.calendar = calendar
        self.today = today
        _startDate = State(initialValue: storedStartDate)
        _endDate = State(initialValue: storedEndDate)
        _displayedMonth = State(initialValue: initialMonth)
    }

    private var cardBackgroundColor: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    private var sectionLabelColor: Color {
        Color(uiColor: .secondaryLabel)
    }

    private var accentColor: Color {
        colorScheme == .dark ? Color(hex: "#A9EBCF") : Color(hex: "#1F8F63")
    }

    private var accentBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#163D34") : Color(hex: "#E8F3EB")
    }

    private var cardStrokeColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.16 : 0.08)
    }

    private var selectedRange: ClosedRange<Date>? {
        guard let startDate, let endDate, startDate <= endDate else {
            return nil
        }

        let daySpan = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        guard daySpan < AppNotificationPreferences.maximumCustomRangeLengthInDays else {
            return nil
        }

        return startDate...endDate
    }

    private var isSaveEnabled: Bool {
        selectedRange != nil
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }

    private var dayCells: [CalendarDayCell] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        let firstMonthWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingDays = (firstMonthWeekday - calendar.firstWeekday + 7) % 7
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthInterval.start) ?? monthInterval.start

        return (0..<42).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else {
                return nil
            }

            return CalendarDayCell(
                date: calendar.startOfDay(for: date),
                isInDisplayedMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
            )
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                selectionSection
                calendarSection
                infoCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Custom Range")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
    }

    private var selectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT RANGE")
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1.2)
                .foregroundStyle(sectionLabelColor)

            VStack(alignment: .leading, spacing: 6) {
                Text("Choose the duration for this recurring notification.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 0) {
                    summaryRow(title: "From", value: formattedDate(startDate))
                    Divider()
                        .padding(.leading, 16)
                    summaryRow(title: "To", value: formattedDate(endDate))
                }
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CALENDAR")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .kerning(1.2)
                    .foregroundStyle(sectionLabelColor)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(monthTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    monthButton(systemName: "chevron.left", isEnabled: canMoveToPreviousMonth) {
                        changeMonth(by: -1)
                    }

                    monthButton(systemName: "chevron.right", isEnabled: true) {
                        changeMonth(by: 1)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol.uppercased())
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 2)
                    }

                    ForEach(dayCells) { cell in
                        dayCellView(cell)
                    }
                }
            }
            .padding(16)
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(cardStrokeColor, lineWidth: 1)
            }
        }
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(accentColor)
                .font(.system(size: 14, weight: .medium))
                .padding(.top, 2)

            Text("Notifications will repeat daily within your selected date range. You can change this at any time in the settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentBackgroundColor.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accentBackgroundColor, lineWidth: 1)
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        let isPlaceholder = (title == "From" && startDate == nil) || (title == "To" && endDate == nil)

        return HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isPlaceholder ? Color.secondary : accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(accentBackgroundColor.opacity(isPlaceholder ? 0.18 : 0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func monthButton(systemName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isEnabled ? accentColor : Color.secondary.opacity(0.4))
                .frame(width: 32, height: 32)
                .background(accentBackgroundColor.opacity(isEnabled ? 0.7 : 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func dayCellView(_ cell: CalendarDayCell) -> some View {
        let isDisabled = !isSelectable(cell)
        let isSelectedStart = startDate == cell.date
        let isSelectedEnd = endDate == cell.date
        let isEndpoint = isSelectedStart || isSelectedEnd
        let isInRange = isDateInSelectedRange(cell.date)

        return Button {
            handleDateTap(cell.date)
        } label: {
            Text(dayNumber(for: cell.date))
                .font(.system(size: 16, weight: isEndpoint ? .semibold : .regular))
                .foregroundStyle(dayForegroundColor(for: cell, isDisabled: isDisabled, isEndpoint: isEndpoint))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(dayBackgroundColor(for: cell, isInRange: isInRange, isEndpoint: isEndpoint))
                )
                .overlay {
                    if isEndpoint {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accentColor, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else {
            return "Select"
        }

        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func dayNumber(for date: Date) -> String {
        String(calendar.component(.day, from: date))
    }

    private func dayForegroundColor(for cell: CalendarDayCell, isDisabled: Bool, isEndpoint: Bool) -> Color {
        if isEndpoint {
            return accentColor
        }

        if !cell.isInDisplayedMonth {
            return Color.secondary.opacity(0.42)
        }

        if isDisabled {
            return Color.secondary.opacity(0.3)
        }

        return .primary
    }

    private func dayBackgroundColor(for cell: CalendarDayCell, isInRange: Bool, isEndpoint: Bool) -> Color {
        if isEndpoint {
            return accentBackgroundColor
        }

        if isInRange && cell.isInDisplayedMonth {
            return accentBackgroundColor.opacity(0.52)
        }

        return .clear
    }

    private var canMoveToPreviousMonth: Bool {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else {
            return false
        }

        return previousMonth >= firstDisplayableMonth
    }

    private var firstDisplayableMonth: Date {
        calendar.dateInterval(of: .month, for: today)?.start ?? today
    }

    private func isSelectable(_ cell: CalendarDayCell) -> Bool {
        guard cell.isInDisplayedMonth, cell.date >= today else {
            return false
        }

        if let startDate, endDate == nil, cell.date < startDate {
            return true
        }

        if let startDate, endDate == nil,
           let latestEndDate = calendar.date(
            byAdding: .day,
            value: AppNotificationPreferences.maximumCustomRangeLengthInDays - 1,
            to: startDate
           ) {
            return cell.date <= latestEndDate
        }

        return true
    }

    private func isDateInSelectedRange(_ date: Date) -> Bool {
        guard let range = selectedRange else {
            return false
        }

        return range.contains(date)
    }

    private func handleDateTap(_ date: Date) {
        if startDate == nil || (startDate != nil && endDate != nil) {
            startDate = date
            endDate = nil
            return
        }

        guard let startDate else {
            return
        }

        if date < startDate {
            self.startDate = date
            endDate = nil
            return
        }

        if let latestEndDate = calendar.date(
            byAdding: .day,
            value: AppNotificationPreferences.maximumCustomRangeLengthInDays - 1,
            to: startDate
        ), date <= latestEndDate {
            endDate = date
        }
    }

    private func changeMonth(by offset: Int) {
        guard let updatedMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else {
            return
        }

        if offset < 0 {
            displayedMonth = max(updatedMonth, firstDisplayableMonth)
        } else {
            displayedMonth = updatedMonth
        }
    }

    private func saveRange() {
        guard let range = selectedRange else {
            return
        }

        var preferences = AppNotificationPreferences.load()
        preferences.setCustomRange(from: range.lowerBound, to: range.upperBound, calendar: calendar)
        preferences.save()

        Task {
            await NotificationManager.shared.syncNotifications(using: preferences)
            await MainActor.run {
                dismiss()
            }
        }
    }

    private var saveButton: some View {
        VStack(spacing: 0) {
            Button {
                saveRange()
            } label: {
                Text("Save Range")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(isSaveEnabled ? Color(hex: "#2E8B44") : Color(uiColor: .systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!isSaveEnabled)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

private struct CalendarDayCell: Identifiable {
    let date: Date
    let isInDisplayedMonth: Bool

    var id: Date { date }
}

#Preview {
    NavigationStack {
        CustomRangeNotificationView()
    }
}
