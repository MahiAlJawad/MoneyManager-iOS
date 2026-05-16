//
//  BudgetView.swift
//  MoneyManager-iOS
//

import SwiftData
import SwiftUI

struct BudgetView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    @AppStorage("budget.monthlyLimit") private var monthlyBudgetLimit: Double = 50_000

    @State private var isEditingLimit = false
    @State private var limitDraft = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                budgetOverviewCard
                spendingBreakdownSection
                budgetTipsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Budget")
        .sheet(isPresented: $isEditingLimit) {
            editLimitSheet
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Budget")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color(uiColor: .label))

            Text("Track spending against your monthly plan")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private var budgetOverviewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("This Month")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text(monthRangeDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer()

                Button {
                    limitDraft = String(format: "%.0f", monthlyBudgetLimit)
                    isEditingLimit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.16), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(monthlyExpense, format: .currency(code: "BDT"))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("of \(monthlyBudgetLimit.formatted(.currency(code: "BDT")))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                budgetProgressBar
                    .padding(.top, 4)

                HStack {
                    Label(budgetStatusTitle, systemImage: budgetStatusSymbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(budgetStatusColor)

                    Spacer()

                    Text(remainingBudget, format: .currency(code: "BDT"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(budgetGradient, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.06 : 0.14), lineWidth: 1)
        }
        .shadow(color: accentColor.opacity(colorScheme == .dark ? 0.2 : 0.28), radius: 20, y: 10)
    }

    private var budgetProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.22))

                Capsule()
                    .fill(.white.opacity(0.95))
                    .frame(width: geometry.size.width * budgetProgress)
            }
        }
        .frame(height: 8)
    }

    private var spendingBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Spending by Category")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(uiColor: .label))

            if categorySpending.isEmpty {
                emptyBreakdownCard
            } else {
                VStack(spacing: 10) {
                    ForEach(categorySpending) { item in
                        categoryRow(item)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(cardStrokeColor, lineWidth: 1)
                }
                .shadow(color: shadowColor, radius: 18, y: 8)
            }
        }
    }

    private var emptyBreakdownCard: some View {
        ContentUnavailableView(
            "No expenses yet",
            systemImage: "chart.pie",
            description: Text("Add expense transactions to see how your budget is distributed.")
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func categoryRow(_ item: CategorySpending) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(item.color)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: item.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(item.color.getContrastColor)
                    }

                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))

                Spacer()

                Text(item.amount, format: .currency(code: "BDT"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(item.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(categoryProgressTrackColor(item.color))

                    Capsule()
                        .fill(categoryProgressFillColor(item.color))
                        .frame(width: geometry.size.width * item.shareOfExpenses)
                }
            }
            .frame(height: 6)
            .padding(.leading, 42)
        }
    }

    private var budgetTipsCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 40, height: 40)
                .background(accentColor.opacity(colorScheme == .dark ? 0.22 : 0.12), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Stay on track")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(uiColor: .label))

                Text("Turn on budget alerts in Settings to get twice-monthly check-in reminders.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: 1)
        }
    }

    private var editLimitSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Monthly limit", text: $limitDraft)
                        .keyboardType(.decimalPad)
                } footer: {
                    Text("Set how much you plan to spend this month.")
                }
            }
            .navigationTitle("Monthly Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditingLimit = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let value = Double(limitDraft.replacingOccurrences(of: ",", with: "")), value > 0 {
                            monthlyBudgetLimit = value
                        }
                        isEditingLimit = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private extension BudgetView {
    struct CategorySpending: Identifiable {
        let name: String
        let amount: Double
        let shareOfExpenses: Double
        let color: Color
        let icon: String

        var id: String { name }
    }

    var accentColor: Color {
        Color(hex: "#1F8F63")
    }

    var overBudgetColor: Color {
        Color(hex: "#E0554D")
    }

    var budgetGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(hex: "#0F5D4F"), Color(hex: "#136959"), Color(hex: "#1B7A67")]
                : [Color(hex: "#156C60"), Color(hex: "#1A7565"), Color(hex: "#2D8571")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var cardBackground: Color {
        Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground)
    }

    var cardStrokeColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04)
    }

    var shadowColor: Color {
        colorScheme == .dark ? .clear : .black.opacity(0.08)
    }

    var allTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }

    var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        return allTransactions.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) &&
                $0.transactionType != .transfer
        }
    }

    var monthlyExpense: Double {
        abs(
            currentMonthTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
    }

    var budgetProgress: Double {
        guard monthlyBudgetLimit > 0 else { return 0 }
        return min(monthlyExpense / monthlyBudgetLimit, 1)
    }

    var remainingBudget: Double {
        max(monthlyBudgetLimit - monthlyExpense, 0)
    }

    var isOverBudget: Bool {
        monthlyExpense > monthlyBudgetLimit
    }

    var budgetStatusTitle: String {
        if isOverBudget {
            return "Over budget"
        }
        if budgetProgress >= 0.85 {
            return "Almost at limit"
        }
        return "On track"
    }

    var budgetStatusSymbol: String {
        if isOverBudget {
            return "exclamationmark.triangle.fill"
        }
        if budgetProgress >= 0.85 {
            return "gauge.with.needle.fill"
        }
        return "checkmark.circle.fill"
    }

    var budgetStatusColor: Color {
        if isOverBudget {
            return Color(hex: "#FFD4CF")
        }
        if budgetProgress >= 0.85 {
            return Color(hex: "#FFE7B0")
        }
        return Color(hex: "#C9F5DF")
    }

    var categorySpending: [CategorySpending] {
        let expenses = currentMonthTransactions.filter { $0.transactionType == .expense }
        guard !expenses.isEmpty else { return [] }

        let grouped = Dictionary(grouping: expenses) { transaction in
            transaction.category.isEmpty ? "Uncategorized" : transaction.category
        }

        let totals = grouped.map { name, transactions in
            (
                name: name,
                amount: abs(transactions.reduce(0) { $0 + $1.amount })
            )
        }
        .sorted { $0.amount > $1.amount }

        let totalExpense = totals.reduce(0) { $0 + $1.amount }
        guard totalExpense > 0 else { return [] }

        return totals.map { item in
            let category = category(for: item.name)
            return CategorySpending(
                name: item.name,
                amount: item.amount,
                shareOfExpenses: item.amount / totalExpense,
                color: category?.color ?? .secondary,
                icon: category?.icon ?? "questionmark"
            )
        }
    }

    func category(for name: String) -> Category? {
        let allCategories: [Category] = Transaction.MainCategory.allCases + Transaction.Subcategory.allCases
        return allCategories.first(where: { $0.name == name })
    }

    func categoryProgressTrackColor(_ color: Color) -> Color {
        color.opacity(colorScheme == .dark ? 0.34 : 0.16)
    }

    func categoryProgressFillColor(_ color: Color) -> Color {
        color.opacity(colorScheme == .dark ? 0.95 : 1)
    }

    var monthRangeDescription: String {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? Date()
        return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
    }
}
