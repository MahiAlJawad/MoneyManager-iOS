//
//  DetailMoneyFlowView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 30/4/26.
//

import Charts
import SwiftData
import SwiftUI

struct DetailMoneyFlowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    @State private var selectedPeriod: MoneyFlowPeriod = .oneMonth
    @State private var selectedMetric: CashflowMetric = .expense
    @State private var selectedFlowPoint: MoneyFlowPoint?
    @State private var snapshot = MoneyFlowSnapshot.empty
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                summarySection
                periodPicker
                metricPicker
                incomeExpenseChartSection
                totalsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle("Money Flow Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshMoneyFlowData()
        }
        .onChange(of: selectedPeriod) { _, _ in
            refreshMoneyFlowData()
        }
        .onChange(of: dataRefreshToken) { _, _ in
            refreshMoneyFlowData()
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(totalBalance, format: .currency(code: "BDT"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            
            Text(periodRangeDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(MoneyFlowPeriod.allCases) { period in
                Text(period.title)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .font(.system(size: 11, weight: .semibold))
    }
    
    private var metricPicker: some View {
        Picker("Money Flow Metric", selection: $selectedMetric) {
            ForEach(CashflowMetric.allCases) { metric in
                Text(metric.title)
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
                    
                    Text(selectedPeriod.description)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                
                flowPointSummary
                
                if chartPoints.contains(where: { $0.income > 0 || $0.expense > 0 }) {
                    Chart {
                        ForEach(chartPoints) { point in
                            BarMark(
                                x: .value("Date", point.date),
                                y: .value("Income", point.income)
                            )
                            .foregroundStyle(incomeColor.opacity(selectedMetric == .income ? 1 : 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            
                            BarMark(
                                x: .value("Date", point.date),
                                y: .value("Expense", -point.expense)
                            )
                            .foregroundStyle(expenseColor.opacity(selectedMetric == .expense ? 1 : 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            
                            if point.date == flowPoint.date {
                                RuleMark(x: .value("Selected Date", point.date))
                                    .foregroundStyle(selectedMetric.tint.opacity(0.26))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                
                                PointMark(
                                    x: .value("Selected Date", point.date),
                                    y: .value("Selected Amount", selectedMetric == .income ? point.income : -point.expense)
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
                        AxisMarks(values: .automatic(desiredCount: 5)) {
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
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
                                                guard let date: Date = proxy.value(atX: xPosition) else {
                                                    return
                                                }
                                                
                                                selectedFlowPoint = nearestPoint(to: date)
                                            }
                                    )
                            }
                        }
                    }
                    
                    flowChartLegend
                } else {
                    emptyState(
                        title: "No money flow yet",
                        subtitle: "Add income or expense transactions to see this chart.",
                        systemImage: "chart.bar.xaxis"
                    )
                }
            }
        }
    }
    
    private var flowPointSummary: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(flowPoint.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(selectedMetric == .income ? flowPoint.income : flowPoint.expense, format: .currency(code: "BDT"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(selectedMetric.tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 4) {
                chartPointPill(title: "Income", amount: flowPoint.income, tint: incomeColor)
                chartPointPill(title: "Expense", amount: flowPoint.expense, tint: expenseColor)
            }
        }
    }
    
    private var totalsSection: some View {
        HStack(spacing: 10) {
            totalCard(title: "Expense", amount: periodExpense, tint: expenseColor, systemImage: "arrow.up")
            totalCard(title: "Income", amount: periodIncome, tint: incomeColor, systemImage: "arrow.down")
            totalCard(title: "Net", amount: periodIncome - periodExpense, tint: balanceColor, systemImage: "plus.forwardslash.minus")
        }
    }
    
    private var flowChartLegend: some View {
        HStack(spacing: 14) {
            legendItem(title: "Income", tint: incomeColor)
            legendItem(title: "Expense", tint: expenseColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func totalCard(title: String, amount: Double, tint: Color, systemImage: String) -> some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(tint.opacity(colorScheme == .dark ? 0.20 : 0.12))
                    )
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(amount, format: .currency(code: "BDT"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
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
    
    private func adaptiveCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
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
}

private extension DetailMoneyFlowView {
    enum MoneyFlowPeriod: String, CaseIterable, Identifiable {
        case oneMonth
        case threeMonths
        case sixMonths
        case oneYear
        case all
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .oneMonth: return "1M"
            case .threeMonths: return "3M"
            case .sixMonths: return "6M"
            case .oneYear: return "1Y"
            case .all: return "All"
            }
        }
        
        var description: String {
            switch self {
            case .oneMonth: return "Last month"
            case .threeMonths: return "Last 3 months"
            case .sixMonths: return "Last 6 months"
            case .oneYear: return "Last year"
            case .all: return "All time"
            }
        }
        
        func startDate(from referenceDate: Date, earliestDate: Date?) -> Date {
            let calendar = Calendar.current
            
            switch self {
            case .oneMonth:
                return calendar.date(byAdding: .month, value: -1, to: referenceDate) ?? referenceDate
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: referenceDate) ?? referenceDate
            case .sixMonths:
                return calendar.date(byAdding: .month, value: -6, to: referenceDate) ?? referenceDate
            case .oneYear:
                return calendar.date(byAdding: .year, value: -1, to: referenceDate) ?? referenceDate
            case .all:
                return earliestDate ?? calendar.date(byAdding: .month, value: -1, to: referenceDate) ?? referenceDate
            }
        }
    }
    
    struct MoneyFlowPoint: Identifiable, Equatable {
        let date: Date
        let income: Double
        let expense: Double
        let balance: Double
        
        var id: Date { date }
    }

    struct MoneyFlowSnapshot {
        let chartPoints: [MoneyFlowPoint]
        let totalBalance: Double
        let periodIncome: Double
        let periodExpense: Double
        let periodRangeDescription: String
        
        static let empty = MoneyFlowSnapshot(
            chartPoints: [],
            totalBalance: 0,
            periodIncome: 0,
            periodExpense: 0,
            periodRangeDescription: MoneyFlowPeriod.oneMonth.description
        )
    }
    
    var allTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }
    
    var moneyFlowTransactions: [Transaction] {
        allTransactions.filter { $0.transactionType != .transfer }
    }
    
    var totalBalance: Double {
        snapshot.totalBalance
    }
    
    var chartPoints: [MoneyFlowPoint] {
        snapshot.chartPoints
    }
    
    var flowPoint: MoneyFlowPoint {
        selectedFlowPoint ?? chartPoints.last(where: { $0.income > 0 || $0.expense > 0 }) ?? chartPoints.last ?? fallbackPoint
    }
    
    var fallbackPoint: MoneyFlowPoint {
        MoneyFlowPoint(date: Date(), income: 0, expense: 0, balance: totalBalance)
    }
    
    var periodIncome: Double {
        snapshot.periodIncome
    }
    
    var periodExpense: Double {
        snapshot.periodExpense
    }
    
    var periodRangeDescription: String {
        snapshot.periodRangeDescription
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
    
    var incomeColor: Color {
        Color(hex: "#1F8F63")
    }
    
    var expenseColor: Color {
        Color(hex: "#E0554D")
    }
    
    var balanceColor: Color {
        colorScheme == .dark ? .white.opacity(0.92) : Color(hex: "#5B5CEB")
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
        let today = calendar.startOfDay(for: .now)
        let totalBalance = accounts.reduce(0) { $0 + $1.accountBalance }
        let transactions = moneyFlowTransactions
        let earliestTransactionDate = transactions.map(\.date).min().map { calendar.startOfDay(for: $0) }
        let start = calendar.startOfDay(for: selectedPeriod.startDate(from: today, earliestDate: earliestTransactionDate))
        let end = max(start, today)
        let endOfPeriod = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: end) ?? end
        let dateRange = makeDateRange(from: start, through: end, calendar: calendar)
        let periodTransactions = transactions.filter { $0.date >= start && $0.date <= endOfPeriod }
        let chartPoints = makeChartPoints(
            for: dateRange,
            from: periodTransactions,
            totalBalance: totalBalance,
            calendar: calendar
        )
        
        snapshot = MoneyFlowSnapshot(
            chartPoints: chartPoints,
            totalBalance: totalBalance,
            periodIncome: periodTransactions
                .filter { $0.transactionType == .income }
                .reduce(0) { $0 + $1.amount },
            periodExpense: abs(
                periodTransactions
                    .filter { $0.transactionType == .expense }
                    .reduce(0) { $0 + $1.amount }
            ),
            periodRangeDescription: dateRangeDescription(for: dateRange)
        )
        selectedFlowPoint = chartPoints.last(where: { $0.income > 0 || $0.expense > 0 }) ?? chartPoints.last
    }
    
    func makeDateRange(from start: Date, through end: Date, calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var currentDate = start
        
        while currentDate <= end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
    
    func makeChartPoints(
        for dateRange: [Date],
        from transactions: [Transaction],
        totalBalance: Double,
        calendar: Calendar
    ) -> [MoneyFlowPoint] {
        let groupedTransactions = Dictionary(grouping: transactions) {
            calendar.startOfDay(for: $0.date)
        }
        var runningBalance = totalBalance - transactions.reduce(0) { $0 + $1.amount }
        
        return dateRange.map { date in
            let transactions = groupedTransactions[date] ?? []
            let income = transactions
                .filter { $0.transactionType == .income }
                .reduce(0) { $0 + $1.amount }
            let expense = abs(
                transactions
                    .filter { $0.transactionType == .expense }
                    .reduce(0) { $0 + $1.amount }
            )
            
            runningBalance += income - expense
            return MoneyFlowPoint(date: date, income: income, expense: expense, balance: runningBalance)
        }
    }
    
    func dateRangeDescription(for dateRange: [Date]) -> String {
        guard let start = dateRange.first, let end = dateRange.last else {
            return selectedPeriod.description
        }
        
        return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
    }
    
    func nearestPoint(to date: Date) -> MoneyFlowPoint? {
        snapshot.chartPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }
    
    func compactCurrency(_ amount: Double) -> String {
        amount.formatted(.currency(code: "BDT").precision(.fractionLength(0)))
    }
}
