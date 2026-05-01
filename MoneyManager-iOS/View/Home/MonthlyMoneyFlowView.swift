//
//  MonthlyMoneyFlowView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 29/4/26.
//

import Charts
import SwiftData
import SwiftUI

enum CashflowMetric: String, CaseIterable, Hashable, Identifiable {
    case expense
    case income
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
    
    var symbolName: String {
        switch self {
        case .expense: return "arrow.up"
        case .income: return "arrow.down"
        }
    }
    
    var tint: Color {
        switch self {
        case .expense: return Color(hex: "#FF5C54")
        case .income: return Color(hex: "#1FB56B")
        }
    }
}

struct MonthlyMoneyFlowView: View {
    @Environment(HomeTabView.Router.self) private var router
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    @State private var selectedMetric: CashflowMetric
    @State private var selectedFlowDay: Int?
    @State private var snapshot = MoneyFlowSnapshot.empty
    let openDetailMoneyFlow: () -> Void
    
    init(initialMetric: CashflowMetric = .income, openDetailMoneyFlow: @escaping () -> Void = {}) {
        _selectedMetric = State(initialValue: initialMetric)
        self.openDetailMoneyFlow = openDetailMoneyFlow
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                metricPicker
                incomeExpenseChartSection
                breakdownSection
                recentCashflowSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle("Money Flow")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshMoneyFlowData()
        }
        .onChange(of: dataRefreshToken) { _, _ in
            refreshMoneyFlowData()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Circle()
                    .fill(selectedMetric.tint.opacity(colorScheme == .dark ? 0.20 : 0.12))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: selectedMetric.symbolName)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(selectedMetric.tint)
                    }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedMetric.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(metricAmount(for: selectedMetric), format: .currency(code: "BDT"))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    HStack(spacing: 5) {
                        Image(systemName: metricTrend.symbolName)
                            .font(.system(size: 10, weight: .bold))
                        
                        Text(metricTrend.description)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(metricTrend.color)
                }
            }
            
            HStack(spacing: 10) {
                Text(monthRangeDescription)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Button {
                    openDetailMoneyFlow()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selectedMetric.tint)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(selectedMetric.tint.opacity(colorScheme == .dark ? 0.20 : 0.12))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open detailed money flow")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var metricPicker: some View {
        Picker("Money Flow Metric", selection: $selectedMetric) {
            ForEach(CashflowMetric.allCases) { metric in
                Text(metric.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .tag(metric)
            }
        }
        .pickerStyle(.segmented)
        .font(.system(size: 11, weight: .semibold))
    }
    
    private var incomeExpenseChartSection: some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income & Expense")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                        
                        Text("Daily money movement")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("This Month")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                flowPointSummary
                
                if dailyCashflow.contains(where: { $0.income != 0 || $0.expense != 0 }) {
                    Chart {
                        ForEach(dailyCashflow) { item in
                            BarMark(
                                x: .value("Day", item.day),
                                yStart: .value("Baseline", 0),
                                yEnd: .value("Income", item.income)
                            )
                            .foregroundStyle(positiveColor.opacity(selectedMetric == .income ? 1 : 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            
                            BarMark(
                                x: .value("Day", item.day),
                                yStart: .value("Baseline", 0),
                                yEnd: .value("Expense", -item.expense)
                            )
                            .foregroundStyle(negativeColor.opacity(selectedMetric == .expense ? 1 : 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            
                            if item.day == selectedFlowDisplayDay {
                                RuleMark(x: .value("Selected Day", item.day))
                                    .foregroundStyle(selectedMetric.tint.opacity(0.26))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                
                                PointMark(
                                    x: .value("Selected Day", item.day),
                                    y: .value("Selected Amount", selectedMetric == .income ? item.income : -item.expense)
                                )
                                .foregroundStyle(selectedMetric.tint)
                                .symbolSize(80)
                            }
                        }
                    }
                    .frame(height: 230)
                    .chartLegend(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 6]))
                                .foregroundStyle(chartGridColor)
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(compactCurrency(amount))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: monthlyAxisMarks) { value in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    Text("\(day)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            if let plotFrame = proxy.plotFrame {
                                let frame = geometry[plotFrame]
                                
                                Rectangle()
                                    .fill(.clear)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let xPosition = value.location.x - frame.origin.x
                                                guard let day: Int = proxy.value(atX: xPosition) else {
                                                    return
                                                }
                                                
                                                selectedFlowDay = nearestDay(to: day)
                                            }
                                    )
                            }
                        }
                    }
                    
                    flowChartLegend
                } else {
                    emptyState(
                        title: "No money flow yet",
                        subtitle: "Add income or expense transactions to see your monthly trend.",
                        systemImage: "chart.bar.xaxis"
                    )
                }
            }
        }
    }
    
    private var flowPointSummary: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedFlowPoint.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(selectedMetric == .income ? selectedFlowPoint.income : selectedFlowPoint.expense, format: .currency(code: "BDT"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(selectedMetric.tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 4) {
                chartPointPill(title: "Income", amount: selectedFlowPoint.income, tint: positiveColor)
                chartPointPill(title: "Expense", amount: selectedFlowPoint.expense, tint: negativeColor)
            }
        }
    }
    
    private var flowChartLegend: some View {
        HStack(spacing: 14) {
            legendItem(title: "Income", tint: positiveColor)
            legendItem(title: "Expense", tint: negativeColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(breakdownTitle)
            
            adaptiveCard {
                if breakdownRows.isEmpty {
                    emptyState(
                        title: "Nothing to break down",
                        subtitle: "Money flow categories will appear here once matching transactions are added.",
                        systemImage: "square.grid.2x2"
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(breakdownRows.enumerated()), id: \.element.id) { index, row in
                            breakdownRow(row)
                            
                            if index < breakdownRows.count - 1 {
                                Divider()
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var recentCashflowSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading(recentSectionTitle)
                Spacer()
                
                if !transactions(for: selectedMetric).isEmpty {
                    Button {
                        router.navigate(to: .cashflowTransactionsView(selectedMetric))
                    } label: {
                        HStack(spacing: 6) {
                            Text("See All")
                                .font(.system(size: 16, weight: .medium))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("See all \(selectedMetric.title) transactions")
                }
            }
            
            adaptiveCard {
                if recentTransactions.isEmpty {
                    emptyState(
                        title: "No recent activity",
                        subtitle: "Income and expense transactions will show here.",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                            transactionRow(for: transaction)
                            
                            if index < recentTransactions.count - 1 {
                                Divider()
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func chartPointPill(title: String, amount: Double, tint: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(tint)
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(amount, format: .currency(code: "BDT"))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    private func legendItem(title: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(tint)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    private func breakdownRow(_ row: CashflowBreakdownRow) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(row.tint.opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: row.symbolName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(row.tint)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(row.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(row.amount, format: .currency(code: "BDT"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.07))
                        
                        Capsule(style: .continuous)
                            .fill(row.tint)
                            .frame(width: max(8, proxy.size.width * row.share))
                    }
                }
                .frame(height: 6)
                
                Text("\((row.share * 100).formatted(.number.precision(.fractionLength(0))))% of \(breakdownShareLabel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 12)
    }
    
    private func transactionRow(for transaction: Transaction) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(transactionTint(for: transaction).opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: transactionIcon(for: transaction))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(transactionTint(for: transaction))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transactionTitle(for: transaction))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: "BDT"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(transaction.transactionType == .income ? positiveColor : negativeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 12)
    }
    
    private func adaptiveCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(cardStrokeColor, lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: 18, y: 8)
    }
    
    private func emptyState(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(primaryTextColor)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
    
    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(primaryTextColor)
    }
}

private extension MonthlyMoneyFlowView {
    struct DailyCashflow: Identifiable {
        let day: Int
        let date: Date
        let income: Double
        let expense: Double
        let balance: Double
        
        var id: Int { day }
    }
    
    struct CashflowBreakdownRow: Identifiable {
        let title: String
        let amount: Double
        let share: Double
        let symbolName: String
        let tint: Color
        
        var id: String { title }
    }
    
    struct CashflowTrend {
        let description: String
        let symbolName: String
        let color: Color
    }
    
    struct MoneyFlowSnapshot {
        let allTransactions: [Transaction]
        let cashflowTransactions: [Transaction]
        let previousMonthTransactions: [Transaction]
        let dailyCashflow: [DailyCashflow]
        let totalBalance: Double
        let monthRangeDescription: String
        
        static let empty = MoneyFlowSnapshot(
            allTransactions: [],
            cashflowTransactions: [],
            previousMonthTransactions: [],
            dailyCashflow: [],
            totalBalance: 0,
            monthRangeDescription: ""
        )
    }
    
    var allTransactions: [Transaction] {
        snapshot.allTransactions
    }
    
    var cashflowTransactions: [Transaction] {
        snapshot.cashflowTransactions
    }
    
    var previousMonthTransactions: [Transaction] {
        snapshot.previousMonthTransactions
    }
    
    var monthlyIncome: Double {
        cashflowTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var previousMonthIncome: Double {
        previousMonthTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpense: Double {
        abs(
            cashflowTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
    }
    
    var previousMonthExpense: Double {
        abs(
            previousMonthTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
    }
    
    var metricTrend: CashflowTrend {
        switch selectedMetric {
        case .expense:
            return cashflowTrend(current: monthlyExpense, previous: previousMonthExpense)
        case .income:
            return cashflowTrend(current: monthlyIncome, previous: previousMonthIncome)
        }
    }
    
    var dailyCashflow: [DailyCashflow] {
        snapshot.dailyCashflow
    }
    
    var selectedFlowDisplayDay: Int {
        selectedFlowDay ?? dailyCashflow.last(where: { $0.income != 0 || $0.expense != 0 })?.day ?? Calendar.current.component(.day, from: Date())
    }
    
    var selectedFlowPoint: DailyCashflow {
        dailyCashflow.first { $0.day == selectedFlowDisplayDay } ?? dailyCashflow.last ?? fallbackDailyCashflow
    }
    
    var fallbackDailyCashflow: DailyCashflow {
        DailyCashflow(
            day: Calendar.current.component(.day, from: Date()),
            date: Date(),
            income: 0,
            expense: 0,
            balance: totalBalance
        )
    }
    
    var monthlyAxisMarks: [Int] {
        let days = dailyCashflow.map(\.day)
        guard let lastDay = days.last else {
            return []
        }
        
        var marks = Array(stride(from: 1, through: lastDay, by: 5))
        if marks.last != lastDay {
            marks.append(lastDay)
        }
        return marks
    }
    
    var breakdownRows: [CashflowBreakdownRow] {
        let transactions = transactions(for: selectedMetric)
        let total = max(transactions.reduce(0) { $0 + abs($1.amount) }, 0.01)
        let grouped = Dictionary(grouping: transactions) { transactionTitle(for: $0) }
        
        return grouped
            .map { title, transactions in
                let amount = transactions.reduce(0) { $0 + abs($1.amount) }
                let sample = transactions.first
                
                return CashflowBreakdownRow(
                    title: title,
                    amount: amount,
                    share: amount / total,
                    symbolName: sample.map(transactionIcon(for:)) ?? "dollarsign.circle",
                    tint: sample.map(transactionTint(for:)) ?? selectedMetric.tint
                )
            }
            .sorted { $0.amount > $1.amount }
            .prefix(5)
            .map { $0 }
    }
    
    var recentTransactions: [Transaction] {
        Array(transactions(for: selectedMetric).prefix(5))
    }
    
    var breakdownTitle: String {
        switch selectedMetric {
        case .expense: return "Expense Breakdown"
        case .income: return "Income Breakdown"
        }
    }
    
    var breakdownShareLabel: String {
        switch selectedMetric {
        case .expense:
            return "expenses"
        case .income:
            return "income"
        }
    }
    
    var recentSectionTitle: String {
        switch selectedMetric {
        case .expense: return "Recent Expenses"
        case .income: return "Recent Income"
        }
    }
    
    var monthRangeDescription: String {
        snapshot.monthRangeDescription
    }
    
    var screenBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    var cardBackground: Color {
        Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground)
    }
    
    var cardStrokeColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04)
    }
    
    var primaryTextColor: Color {
        Color(uiColor: .label)
    }
    
    var shadowColor: Color {
        colorScheme == .dark ? .clear : .black.opacity(0.08)
    }
    
    var chartGridColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.08)
    }
    
    var positiveColor: Color {
        Color(hex: "#1F8F63")
    }
    
    var negativeColor: Color {
        Color(hex: "#E0554D")
    }
    
    var netBalanceColor: Color {
        colorScheme == .dark ? .white.opacity(0.92) : Color(hex: "#5B5CEB")
    }
    
    var totalBalance: Double {
        snapshot.totalBalance
    }
    
    var dataRefreshToken: String {
        accounts.map { account in
            let transactionToken = account.transactions
                .map { "\($0.id):\($0.amount):\($0.date.timeIntervalSince1970)" }
                .joined(separator: "|")
            return "\(account.id):\(account.accountBalance):\(transactionToken)"
        }
        .joined(separator: "#")
    }
    
    func refreshMoneyFlowData() {
        let calendar = Calendar.current
        let allTransactions = accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
        let totalBalance = accounts.reduce(0) { $0 + $1.accountBalance }
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? Date()
        let cashflowTransactions = allTransactions.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) &&
                $0.transactionType != .transfer
        }
        
        let previousMonthTransactions: [Transaction]
        if let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) {
            previousMonthTransactions = allTransactions.filter {
                calendar.isDate($0.date, equalTo: previousMonthDate, toGranularity: .month)
            }
        } else {
            previousMonthTransactions = []
        }
        
        snapshot = MoneyFlowSnapshot(
            allTransactions: allTransactions,
            cashflowTransactions: cashflowTransactions,
            previousMonthTransactions: previousMonthTransactions,
            dailyCashflow: makeDailyCashflow(
                from: cashflowTransactions,
                monthStart: monthStart,
                totalBalance: totalBalance
            ),
            totalBalance: totalBalance,
            monthRangeDescription: "\(monthStart.formatted(date: .abbreviated, time: .omitted)) - \(monthEnd.formatted(date: .abbreviated, time: .omitted))"
        )
    }
    
    func makeDailyCashflow(from transactions: [Transaction], monthStart: Date, totalBalance: Double) -> [DailyCashflow] {
        let calendar = Calendar.current
        let groupedTransactions = Dictionary(grouping: transactions) {
            calendar.component(.day, from: $0.date)
        }
        
        guard let days = calendar.range(of: .day, in: .month, for: Date()) else {
            return []
        }
        
        var runningBalance = totalBalance - transactions.reduce(0) { $0 + $1.amount }
        
        return days.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else {
                return nil
            }
            
            let transactions = groupedTransactions[day] ?? []
            let income = transactions
                .filter { $0.transactionType == .income }
                .reduce(0) { $0 + $1.amount }
            let expense = abs(
                transactions
                    .filter { $0.transactionType == .expense }
                    .reduce(0) { $0 + $1.amount }
            )
            
            runningBalance += income - expense
            return DailyCashflow(day: day, date: date, income: income, expense: expense, balance: runningBalance)
        }
    }
    
    func transactions(for metric: CashflowMetric) -> [Transaction] {
        switch metric {
        case .expense:
            return cashflowTransactions.filter { $0.transactionType == .expense }
        case .income:
            return cashflowTransactions.filter { $0.transactionType == .income }
        }
    }
    
    func metricAmount(for metric: CashflowMetric) -> Double {
        switch metric {
        case .expense: return monthlyExpense
        case .income: return monthlyIncome
        }
    }
    
    func transactionTitle(for transaction: Transaction) -> String {
        if transaction.transactionType == .income, transaction.category.isEmpty {
            return "Income"
        }
        
        if transaction.category.isEmpty {
            return transaction.transactionType.description
        }
        
        return transaction.category
    }
    
    func transactionIcon(for transaction: Transaction) -> String {
        if transaction.transactionType == .income {
            return transaction.transactionCategory?.icon ?? "arrow.down.circle.fill"
        }
        
        return transaction.transactionCategory?.icon ?? "dollarsign.circle"
    }
    
    func transactionTint(for transaction: Transaction) -> Color {
        switch transaction.transactionType {
        case .income:
            return transaction.transactionCategory?.color ?? CashflowMetric.income.tint
        case .expense:
            return transaction.transactionCategory?.color ?? CashflowMetric.expense.tint
        case .transfer:
            return Color(hex: "#8A63FF")
        }
    }
    
    func compactCurrency(_ amount: Double) -> String {
        amount.formatted(.currency(code: "BDT").precision(.fractionLength(0)))
    }
    
    func nearestDay(to day: Int) -> Int {
        guard let nearest = dailyCashflow.min(by: { abs($0.day - day) < abs($1.day - day) }) else {
            return day
        }
        
        return nearest.day
    }
    
    func cashflowTrend(current: Double, previous: Double) -> CashflowTrend {
        guard !previousMonthTransactions.isEmpty else {
            return CashflowTrend(
                description: "No history",
                symbolName: "minus",
                color: Color.secondary
            )
        }
        
        guard current != 0 else {
            return CashflowTrend(
                description: "No activity",
                symbolName: "minus",
                color: Color.secondary
            )
        }
        
        let delta = current - previous
        guard previous != 0 else {
            return CashflowTrend(
                description: "New this month",
                symbolName: "arrow.up",
                color: positiveColor
            )
        }
        
        let percentage = abs((delta / previous) * 100)
        
        return CashflowTrend(
            description: "\(percentage.formatted(.number.precision(.fractionLength(1))))% from last month",
            symbolName: delta >= 0 ? "arrow.up" : "arrow.down",
            color: delta >= 0 ? positiveColor : negativeColor
        )
    }
}
