//
//  CustomRangeNotificationView.swift
//  MoneyManager-iOS
//

import SwiftUI

struct CustomRangeNotificationView: View {
    private enum ActiveRangeField {
        case start
        case end
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var displayedMonth: Date
    @State private var activeField: ActiveRangeField = .start

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
                    summaryRow(title: "From", value: formattedDate(startDate), field: .start)
                    Divider()
                        .padding(.leading, 16)
                    summaryRow(title: "To", value: formattedDate(endDate), field: .end)
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

    private func summaryRow(title: String, value: String, field: ActiveRangeField) -> some View {
        let selectedDate = field == .start ? startDate : endDate
        let isPlaceholder = selectedDate == nil
        let isActive = activeField == field

        return Button {
            focus(field)
        } label: {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 8) {
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if isActive {
                        RoundedRectangle(cornerRadius: 1, style: .continuous)
                            .fill(accentColor.opacity(0.8))
                            .frame(width: 2, height: 18)
                    }
                }
                .foregroundStyle(isPlaceholder ? Color.secondary : accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accentBackgroundColor.opacity(isActive ? 0.82 : (isPlaceholder ? 0.18 : 0.6)))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isActive ? accentColor : Color.clear, lineWidth: isActive ? 2 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? accentBackgroundColor.opacity(0.14) : .clear)
            )
        }
        .buttonStyle(.plain)
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
        let isActiveEndpoint = (activeField == .start && isSelectedStart) || (activeField == .end && isSelectedEnd)

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
                        Circle()
                            .stroke(accentColor, lineWidth: isActiveEndpoint ? 2.5 : 1.5)
                            .padding(1)
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
            return .white
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
            return accentColor
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

        let maximumOffset = AppNotificationPreferences.maximumCustomRangeLengthInDays - 1

        switch activeField {
        case .start:
            guard let endDate else {
                return true
            }

            let earliestAllowedStart = calendar.date(byAdding: .day, value: -maximumOffset, to: endDate) ?? endDate
            return cell.date >= max(today, earliestAllowedStart) && cell.date <= endDate
        case .end:
            guard let startDate else {
                return true
            }

            let latestAllowedEnd = calendar.date(byAdding: .day, value: maximumOffset, to: startDate) ?? startDate
            return cell.date >= startDate && cell.date <= latestAllowedEnd
        }
    }

    private func isDateInSelectedRange(_ date: Date) -> Bool {
        guard let range = selectedRange else {
            return false
        }

        return range.contains(date)
    }

    private func handleDateTap(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        let maximumOffset = AppNotificationPreferences.maximumCustomRangeLengthInDays - 1

        switch activeField {
        case .start:
            startDate = normalizedDate

            if let currentEndDate = endDate {
                if normalizedDate > currentEndDate {
                    endDate = normalizedDate
                } else if let earliestAllowedStart = calendar.date(byAdding: .day, value: -maximumOffset, to: currentEndDate),
                          normalizedDate < earliestAllowedStart {
                    endDate = calendar.date(byAdding: .day, value: maximumOffset, to: normalizedDate)
                }
            } else {
                endDate = normalizedDate
            }
        case .end:
            endDate = normalizedDate

            if let currentStartDate = startDate {
                if normalizedDate < currentStartDate {
                    startDate = normalizedDate
                } else if let latestAllowedEnd = calendar.date(byAdding: .day, value: maximumOffset, to: currentStartDate),
                          normalizedDate > latestAllowedEnd {
                    startDate = calendar.date(byAdding: .day, value: -maximumOffset, to: normalizedDate)
                }
            } else {
                startDate = normalizedDate
            }
        }
    }

    private func focus(_ field: ActiveRangeField) {
        activeField = field

        let dateToShow = field == .start ? startDate : endDate
        guard let dateToShow,
              let targetMonth = calendar.dateInterval(of: .month, for: dateToShow)?.start else {
            return
        }

        displayedMonth = max(targetMonth, firstDisplayableMonth)
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
