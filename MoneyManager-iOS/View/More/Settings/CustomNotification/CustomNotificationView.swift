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
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title: String = ""
    @State private var selectedRepeatOption: RepeatOption = .once
    @State private var reminderTime: Date = .now
    @State private var startDate: Date = .now
    @State private var isSoundEnabled: Bool = false
    @State private var isBadgeOnIconEnabled: Bool = false

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

    private var formattedStartDate: String {
        startDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                titleSection
                repeatSection
                repeatHintCard
                scheduleSection
                optionsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Custom Remainder")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }
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
            selectedRepeatOption = option
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

            Text("Notification repeats daily within your selected date range.")
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

            VStack(spacing: 0) {
                scheduleRow(
                    icon: "clock.fill",
                    title: "Time",
                    value: formattedTime
                ) {
                    // UI-only screen; time picker behavior will be connected later.
                }

                Divider()
                    .padding(.leading, 56)

                scheduleRow(
                    icon: "calendar",
                    title: "Start date",
                    value: formattedStartDate
                ) {
                    // UI-only screen; date picker behavior will be connected later.
                }
            }
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func scheduleRow(
        icon: String,
        title: String,
        value: String,
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
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OPTIONS")
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1.2)
                .foregroundStyle(sectionLabelColor)

            VStack(spacing: 0) {
                toggleOptionRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: accentColor,
                    iconBackgroundColor: accentBackgroundColor,
                    title: "Sound",
                    isOn: $isSoundEnabled
                )

                Divider()
                    .padding(.leading, 56)

                toggleOptionRow(
                    icon: "app.badge.fill",
                    iconColor: Color(hex: "#4B9BE3"),
                    iconBackgroundColor: Color(hex: "#DCEBFA"),
                    title: "Badge on icon",
                    isOn: $isBadgeOnIconEnabled
                )
            }
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func toggleOptionRow(
        icon: String,
        iconColor: Color,
        iconBackgroundColor: Color,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
                .background(iconBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var saveButton: some View {
        VStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Text("Save Notification")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(Color(hex: "#2E8B44"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

#Preview {
    NavigationStack {
        CustomNotificationView()
    }
}
