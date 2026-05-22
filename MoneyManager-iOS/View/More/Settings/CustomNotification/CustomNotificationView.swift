//
//  CustomNotificationView.swift
//  MoneyManager-iOS
//

import SwiftUI

struct CustomNotificationView: View {
    private enum RepeatOption: String, CaseIterable, Identifiable {
        case once = "Once"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case customRange = "Custom range"

        var id: String { rawValue }

        var subtitle: String {
            switch self {
            case .once:
                return "Notify on a single date"
            case .daily:
                return "Every day at set time"
            case .weekly:
                return "Same day every week"
            case .monthly:
                return "Same date every month"
            case .customRange:
                return "Pick a start and end date"
            }
        }

        var bannerText: String {
            switch self {
            case .once:
                return "A single notification will be sent at the selected date and time."
            case .daily:
                return "Repeats every day at the set time until you turn it off."
            case .weekly:
                return "Repeats every week on the same day within your selected start and end dates."
            case .monthly:
                return "Repeats every month on the same date within your selected start and end dates."
            case .customRange:
                return "Notification repeats daily within your selected date range."
            }
        }

        var recurrence: CustomNotificationRecurrence {
            switch self {
            case .once:
                return .once
            case .daily:
                return .daily
            case .weekly:
                return .weekly
            case .monthly:
                return .monthly
            case .customRange:
                return .customRange
            }
        }

        init(recurrence: CustomNotificationRecurrence) {
            switch recurrence {
            case .once:
                self = .once
            case .daily:
                self = .daily
            case .weekly:
                self = .weekly
            case .monthly:
                self = .monthly
            case .customRange:
                self = .customRange
            }
        }
    }

    private enum ActiveDateField {
        case onceDate
        case startDate
        case endDate
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title: String = ""
    @State private var selectedRepeatOption: RepeatOption = .daily
    @State private var reminderTime: Date = .now
    @State private var oneTimeDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var recurringStartDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var recurringEndDate: Date?
    @State private var customRangeStartDate: Date?
    @State private var customRangeEndDate: Date?
    @State private var isTimePickerPresented = false
    @State private var isCustomRangePresented = false
    @State private var activeDateField: ActiveDateField?
    @State private var hasLoadedInitialState = false
    @State private var shouldShowCustomRangeValidation = false

    private let calendar = Calendar.current

    private var today: Date {
        calendar.startOfDay(for: .now)
    }

    private var maxStartDate: Date {
        calendar.date(byAdding: .day, value: 30, to: today) ?? today
    }

    private var maxEndDate: Date {
        calendar.date(byAdding: .day, value: 365, to: today) ?? maxStartDate
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

    private var formattedTime: String {
        reminderTime.formatted(date: .omitted, time: .shortened)
    }

    private var formattedOneTimeDate: String {
        oneTimeDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var formattedRecurringStartDate: String {
        recurringStartDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var formattedRecurringEndDate: String {
        guard let recurringEndDate else {
            return "Select"
        }

        return recurringEndDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var formattedCustomRangeStartDate: String {
        guard let customRangeStartDate else {
            return "Select"
        }

        return customRangeStartDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var formattedCustomRangeEndDate: String {
        guard let customRangeEndDate else {
            return "Select"
        }

        return customRangeEndDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var dayOfWeekText: String {
        recurringStartDate.formatted(.dateTime.weekday(.wide))
    }

    private var dayOfMonthText: String {
        ordinalString(for: calendar.component(.day, from: recurringStartDate))
    }

    private var isCustomRangeValid: Bool {
        guard let customRangeStartDate, let customRangeEndDate else {
            return false
        }

        return customRangeEndDate > customRangeStartDate
    }

    private var isSaveEnabled: Bool {
        switch selectedRepeatOption {
        case .customRange:
            return isCustomRangeValid
        case .once, .daily, .weekly, .monthly:
            return true
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                titleSection
                repeatSection
                repeatHintCard
                scheduleSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Custom Notification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $isCustomRangePresented) {
            CustomRangeNotificationView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if hasLoadedInitialState {
                refreshCustomRangeSelection()
            } else {
                loadPreferences()
                hasLoadedInitialState = true
            }
        }
        .onChange(of: recurringStartDate) { _, newValue in
            let clampedStartDate = clampDate(newValue, min: today, max: maxStartDate)
            if clampedStartDate != newValue {
                recurringStartDate = clampedStartDate
                return
            }

            recurringEndDate = clampedRecurringEndDate(for: selectedRepeatOption, startDate: clampedStartDate, currentEndDate: recurringEndDate)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TITLE")
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1.2)
                .foregroundStyle(sectionLabelColor)

            TextField("e.g. Pay electricity bill", text: $title)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REPEAT")
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1.2)
                .foregroundStyle(sectionLabelColor)

            VStack(spacing: 0) {
                ForEach(RepeatOption.allCases) { option in
                    repeatOptionRow(option)

                    if option != RepeatOption.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func repeatOptionRow(_ option: RepeatOption) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.22)) {
                selectedRepeatOption = option
                activeDateField = nil
                isTimePickerPresented = false
                shouldShowCustomRangeValidation = option == .customRange && !isCustomRangeValid
                applyDefaults(for: option)
            }

            if option == .customRange {
                isCustomRangePresented = true
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(option.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(option.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if selectedRepeatOption == option {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(accentColor)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(uiColor: .systemGray4))
                }

                if option == .customRange {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedRepeatOption == option ? accentBackgroundColor.opacity(0.35) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var repeatHintCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(accentColor)
                .font(.system(size: 14, weight: .medium))
                .padding(.top, 2)

            Text(selectedRepeatOption.bannerText)
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

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SCHEDULE")
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1.2)
                .foregroundStyle(sectionLabelColor)

            scheduleCard

            if shouldShowCustomRangeValidation && selectedRepeatOption == .customRange {
                Text("Please select a valid end date after the start date.")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 4)
            }
        }
        .animation(.snappy(duration: 0.22), value: selectedRepeatOption)
        .animation(.snappy(duration: 0.22), value: activeDateField)
        .animation(.snappy(duration: 0.22), value: isTimePickerPresented)
    }

    private var scheduleCard: some View {
        VStack(spacing: 0) {
            timeScheduleRow

            if isTimePickerPresented {
                Divider()
                    .padding(.leading, 56)

                DatePicker(
                    "Reminder time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }

            scheduleRows
        }
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var scheduleRows: some View {
        switch selectedRepeatOption {
        case .once:
            dividerBeforeScheduleRow
            dateActionRow(
                icon: "calendar",
                title: "Date",
                value: formattedOneTimeDate,
                isActive: activeDateField == .onceDate
            ) {
                toggleDateField(.onceDate)
            }

            if activeDateField == .onceDate {
                dividerBeforeScheduleRow
                scheduleDatePicker(
                    selection: $oneTimeDate,
                    range: today...maxStartDate
                )
            }

        case .daily:
            EmptyView()

        case .weekly:
            recurringRows(showWeekday: true, showMonthDay: false)

        case .monthly:
            recurringRows(showWeekday: false, showMonthDay: true)

        case .customRange:
            dividerBeforeScheduleRow
            dateActionRow(
                icon: "calendar",
                title: "Start date",
                value: formattedCustomRangeStartDate,
                isActive: false
            ) {
                isCustomRangePresented = true
            }

            dividerBeforeScheduleRow
            dateActionRow(
                icon: "calendar.badge.clock",
                title: "End date",
                value: formattedCustomRangeEndDate,
                isActive: false
            ) {
                isCustomRangePresented = true
            }
        }
    }

    @ViewBuilder
    private func recurringRows(showWeekday: Bool, showMonthDay: Bool) -> some View {
        dividerBeforeScheduleRow
        dateActionRow(
            icon: "calendar",
            title: "Start date",
            value: formattedRecurringStartDate,
            isActive: activeDateField == .startDate
        ) {
            toggleDateField(.startDate)
        }

        if activeDateField == .startDate {
            dividerBeforeScheduleRow
            scheduleDatePicker(
                selection: $recurringStartDate,
                range: today...maxStartDate
            )
        }

        dividerBeforeScheduleRow
        dateActionRow(
            icon: "calendar.badge.clock",
            title: "End date",
            value: formattedRecurringEndDate,
            isActive: activeDateField == .endDate
        ) {
            toggleDateField(.endDate)
        }

        if activeDateField == .endDate {
            dividerBeforeScheduleRow
            scheduleDatePicker(
                selection: recurringEndDateBinding,
                range: recurringStartDate...maxEndDate
            )
        }

        if showWeekday {
            dividerBeforeScheduleRow
            staticScheduleRow(
                icon: "calendar.badge.clock",
                title: "Day of week",
                value: dayOfWeekText
            )
        }

        if showMonthDay {
            dividerBeforeScheduleRow
            staticScheduleRow(
                icon: "calendar.badge.plus",
                title: "Day of month",
                value: dayOfMonthText
            )
        }
    }

    private var dividerBeforeScheduleRow: some View {
        Divider()
            .padding(.leading, 56)
    }

    private var timeScheduleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 30, height: 30)
                .background(accentBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text("Time")
                .foregroundStyle(.primary)
                .font(.body)

            Spacer()

            Button {
                activeDateField = nil
                withAnimation(.snappy(duration: 0.22)) {
                    isTimePickerPresented.toggle()
                }
            } label: {
                Text(formattedTime)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(accentBackgroundColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func dateActionRow(
        icon: String,
        title: String,
        value: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .frame(width: 30, height: 30)
                    .background(accentBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(title)
                    .foregroundStyle(.primary)
                    .font(.body)

                Spacer()

                Text(value)
                    .foregroundStyle(isActive ? accentColor : Color.secondary)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isActive ? accentBackgroundColor.opacity(0.18) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private func staticScheduleRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 30, height: 30)
                .background(accentBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .foregroundStyle(.primary)
                .font(.body)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func scheduleDatePicker(selection: Binding<Date>, range: ClosedRange<Date>) -> some View {
        DatePicker(
            "",
            selection: selection,
            in: range,
            displayedComponents: .date
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }

    private var recurringEndDateBinding: Binding<Date> {
        Binding(
            get: { recurringEndDate ?? defaultRecurringEndDate(for: selectedRepeatOption, startDate: recurringStartDate) },
            set: { newValue in
                let normalizedDate = calendar.startOfDay(for: newValue)
                recurringEndDate = clampDate(normalizedDate, min: recurringStartDate, max: maxEndDate)
            }
        )
    }

    private var saveButton: some View {
        VStack(spacing: 0) {
            Button {
                handleSaveTap()
            } label: {
                Text("Save Notification")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(isSaveEnabled ? Color(hex: "#2E8B44") : Color(uiColor: .systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private func toggleDateField(_ field: ActiveDateField) {
        isTimePickerPresented = false

        withAnimation(.snappy(duration: 0.22)) {
            activeDateField = activeDateField == field ? nil : field
        }
    }

    private func loadPreferences() {
        let preferences = AppNotificationPreferences.load()

        reminderTime = preferences.reminderDate
        selectedRepeatOption = RepeatOption(recurrence: preferences.customNotificationRecurrence)
        oneTimeDate = clampDate(preferences.normalizedOneTimeNotificationDate ?? today, min: today, max: maxStartDate)
        recurringStartDate = clampDate(preferences.normalizedRecurringStartDate ?? today, min: today, max: maxStartDate)
        recurringEndDate = clampedRecurringEndDate(
            for: selectedRepeatOption,
            startDate: recurringStartDate,
            currentEndDate: preferences.recurringNotificationEndDate.map { calendar.startOfDay(for: $0) }
        )
        customRangeStartDate = preferences.customRangeStartDate.map { calendar.startOfDay(for: $0) }
        customRangeEndDate = preferences.customRangeEndDate.map { calendar.startOfDay(for: $0) }
        shouldShowCustomRangeValidation = selectedRepeatOption == .customRange && !isCustomRangeValid
    }

    private func refreshCustomRangeSelection() {
        let preferences = AppNotificationPreferences.load()
        customRangeStartDate = preferences.customRangeStartDate.map { calendar.startOfDay(for: $0) }
        customRangeEndDate = preferences.customRangeEndDate.map { calendar.startOfDay(for: $0) }

        if selectedRepeatOption == .customRange {
            shouldShowCustomRangeValidation = !isCustomRangeValid
        }
    }

    private func handleSaveTap() {
        guard selectedRepeatOption != .customRange || isCustomRangeValid else {
            shouldShowCustomRangeValidation = true
            return
        }

        shouldShowCustomRangeValidation = false

        var preferences = AppNotificationPreferences.load()
        preferences.updateReminderTime(from: reminderTime)
        preferences.customNotificationRecurrence = selectedRepeatOption.recurrence

        switch selectedRepeatOption {
        case .once:
            preferences.setOneTimeNotificationDate(oneTimeDate, calendar: calendar)
        case .daily, .weekly, .monthly:
            preferences.setRecurringStartDate(recurringStartDate, calendar: calendar)
            let boundedEndDate = selectedRepeatOption == .daily
                ? nil
                : clampedRecurringEndDate(for: selectedRepeatOption, startDate: recurringStartDate, currentEndDate: recurringEndDate)
            preferences.setRecurringEndDate(boundedEndDate, calendar: calendar)
        case .customRange:
            if let customRangeStartDate, let customRangeEndDate {
                preferences.setCustomRange(from: customRangeStartDate, to: customRangeEndDate, calendar: calendar)
            }
        }

        preferences.save()

        Task {
            await NotificationManager.shared.syncNotifications(using: preferences)
            await MainActor.run {
                dismiss()
            }
        }
    }

    private func ordinalString(for number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func clampDate(_ date: Date, min minimumDate: Date, max maximumDate: Date) -> Date {
        let normalizedDate = calendar.startOfDay(for: date)
        let normalizedMinimum = calendar.startOfDay(for: minimumDate)
        let normalizedMaximum = calendar.startOfDay(for: maximumDate)

        if normalizedDate < normalizedMinimum {
            return normalizedMinimum
        }

        if normalizedDate > normalizedMaximum {
            return normalizedMaximum
        }

        return normalizedDate
    }

    private func applyDefaults(for option: RepeatOption) {
        switch option {
        case .once:
            oneTimeDate = clampDate(oneTimeDate, min: today, max: maxStartDate)
        case .daily:
            recurringEndDate = nil
        case .weekly:
            recurringStartDate = clampDate(recurringStartDate, min: today, max: maxStartDate)
            recurringEndDate = clampedRecurringEndDate(for: option, startDate: recurringStartDate, currentEndDate: recurringEndDate)
        case .monthly:
            recurringStartDate = clampDate(recurringStartDate, min: today, max: maxStartDate)
            recurringEndDate = monthlyDefaultAwareEndDate(startDate: recurringStartDate, currentEndDate: recurringEndDate)
        case .customRange:
            break
        }
    }

    private func defaultRecurringEndDate(for option: RepeatOption, startDate: Date) -> Date {
        let baseEndDate: Date

        switch option {
        case .weekly:
            baseEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today
        case .monthly:
            baseEndDate = calendar.date(byAdding: .day, value: 30, to: today) ?? today
        case .once, .daily, .customRange:
            baseEndDate = startDate
        }

        return clampDate(baseEndDate, min: startDate, max: maxEndDate)
    }

    private func monthlyDefaultAwareEndDate(startDate: Date, currentEndDate: Date?) -> Date {
        let defaultMonthlyEndDate = defaultRecurringEndDate(for: .monthly, startDate: startDate)

        guard let currentEndDate else {
            return defaultMonthlyEndDate
        }

        let normalizedCurrentEndDate = clampDate(currentEndDate, min: startDate, max: maxEndDate)
        let weeklyDefaultEndDate = defaultRecurringEndDate(for: .weekly, startDate: startDate)

        if normalizedCurrentEndDate <= weeklyDefaultEndDate {
            return defaultMonthlyEndDate
        }

        return normalizedCurrentEndDate
    }

    private func clampedRecurringEndDate(
        for option: RepeatOption,
        startDate: Date,
        currentEndDate: Date?
    ) -> Date? {
        switch option {
        case .weekly, .monthly:
            let endDate = currentEndDate ?? defaultRecurringEndDate(for: option, startDate: startDate)
            return clampDate(endDate, min: startDate, max: maxEndDate)
        case .daily:
            return nil
        case .once, .customRange:
            return currentEndDate
        }
    }
}

#Preview {
    NavigationStack {
        CustomNotificationView()
    }
}
