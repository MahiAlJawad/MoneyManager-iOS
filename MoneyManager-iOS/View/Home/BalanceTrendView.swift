//
//  BalanceTrendView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 26/4/26.
//

import Charts
import SwiftData
import SwiftUI

struct BalanceTrendView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    @State private var selectedPeriod: BalancePeriod = .oneMonth
    @State private var selectedPoint: BalancePoint?
    @State private var chartPoints: [BalancePoint] = []
    @State private var dateRange: [Date] = []
    @State private var balanceChangingTransactions: [Transaction] = []
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var customEndDate = Date.now
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                balanceSummarySection
                periodPicker
                balanceChartSection
                accountBreakdownSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle("Balance Trend")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPeriod) { _, _ in
            refreshBalanceData()
        }
        .onChange(of: customStartDate) { _, _ in
            guard selectedPeriod == .custom else {
                return
            }
            
            if customStartDate > customEndDate {
                customEndDate = customStartDate
            }
            
            refreshBalanceData()
        }
        .onChange(of: customEndDate) { _, _ in
            guard selectedPeriod == .custom else {
                return
            }
            
            if customEndDate < customStartDate {
                customStartDate = customEndDate
            }
            
            refreshBalanceData()
        }
        .onAppear {
            refreshBalanceData()
        }
    }
    
    private func refreshBalanceData() {
        let transactions = allTransactions.filter { $0.transactionType != .transfer }
        let range = makeDateRange(from: transactions)
        
        balanceChangingTransactions = transactions
        dateRange = range
        chartPoints = makeChartPoints(for: range, from: transactions)
        
        if let selectedPoint,
           chartPoints.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedPoint.date) }) {
            return
        }
        
        selectedPoint = chartPoints.last
    }
    
    private func makeChartPoints(for range: [Date], from transactions: [Transaction]) -> [BalancePoint] {
        range.map { date in
            BalancePoint(date: date, balance: balance(atEndOf: date, using: transactions))
        }
    }
    
    private func makeDateRange(from transactions: [Transaction]) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let earliestTransactionDate = transactions.map(\.date).min().map { calendar.startOfDay(for: $0) }
        let rangeEnd = selectedPeriod == .custom ? calendar.startOfDay(for: customEndDate) : today
        let start = calendar.startOfDay(for: selectedPeriod.startDate(from: rangeEnd, earliestDate: earliestTransactionDate, customStartDate: customStartDate))
        let end = max(start, rangeEnd)
        
        guard start <= end else {
            return [end]
        }
        
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
    
    private func balance(atEndOf date: Date, using transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: date)) ?? date
        let laterTransactionTotal = transactions
            .filter { $0.date > endOfDay }
            .reduce(0) { $0 + $1.amount }
        
        return totalBalance - laterTransactionTotal
    }
    
    private var balanceSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Balance")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(totalBalance, format: .currency(code: "BDT"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            
            HStack(spacing: 8) {
                Image(systemName: periodBalanceChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 13, weight: .bold))
                
                Text(periodChangeDescription)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(periodBalanceChange >= 0 ? positiveColor : negativeColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var periodPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Period", selection: $selectedPeriod) {
                ForEach(BalancePeriod.allCases) { period in
                    Text(period.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .tag(period)
                }
            }
            .pickerStyle(.segmented)
            .font(.system(size: 11, weight: .semibold))
            
            if selectedPeriod == .custom {
                adaptiveCard {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            dateField(title: "From", date: $customStartDate, range: ...customEndDate)
                            dateField(title: "To", date: $customEndDate, range: customStartDate...Date.now)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Text(customPeriodDescription)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    private var balanceChartSection: some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 16) {
                selectedPointHeader
                
                if chartPoints.count > 1 {
                    Chart {
                        ForEach(chartPoints) { point in
                            AreaMark(
                                x: .value("Date", point.date),
                                yStart: .value("Baseline", chartLowerBound),
                                yEnd: .value("Balance", point.balance)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [chartColor.opacity(0.28), chartColor.opacity(0.03)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Balance", point.balance)
                            )
                            .foregroundStyle(chartColor)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        }
                        
                        if let selectedPoint {
                            RuleMark(x: .value("Selected Date", selectedPoint.date))
                                .foregroundStyle(chartColor.opacity(0.28))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            
                            PointMark(
                                x: .value("Selected Date", selectedPoint.date),
                                y: .value("Selected Balance", selectedPoint.balance)
                            )
                            .foregroundStyle(chartColor)
                            .symbolSize(90)
                        }
                    }
                    .frame(height: 240)
                    .chartLegend(.hidden)
                    .chartYScale(domain: chartLowerBound...chartUpperBound)
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
                        AxisMarks(values: .automatic(desiredCount: 4)) { value in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(axisLabel(for: date))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            let plotFrame = geometry[proxy.plotFrame!]
                            
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let xPosition = value.location.x - plotFrame.origin.x
                                            guard let date: Date = proxy.value(atX: xPosition) else {
                                                return
                                            }
                                            
                                            selectedPoint = nearestPoint(to: date)
                                        }
                                )
                        }
                    }
                } else {
                    emptyState(
                        title: "No balance history yet",
                        subtitle: "Add transactions over time to see your balance movement.",
                        systemImage: "chart.xyaxis.line"
                    )
                }
                
                chartTransactionsSection
            }
        }
    }
    
    private var chartTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            HStack(spacing: 8) {
                Text(selectedPoint == nil ? "Activity in range" : "Activity on selected date")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(primaryTextColor)
                
                Spacer(minLength: 8)
                
                if selectedTransactions.count > movementDisplayLimit {
                    Text("\(selectedTransactions.count) items")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            if selectedTransactions.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text("No income or expense transactions for this point.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(displayedMovementTransactions.enumerated()), id: \.element.id) { index, transaction in
                        compactMovementRow(for: transaction)
                        
                        if index < displayedMovementTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 42)
                        }
                    }
                }
            }
        }
    }
    
    private var selectedPointHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(chartColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(chartColor)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedPoint?.date.formatted(date: .abbreviated, time: .omitted) ?? selectedPeriod.description)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text((selectedPoint?.balance ?? totalBalance), format: .currency(code: "BDT"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                
                if let selectedPoint {
                    Text(pointChangeDescription(for: selectedPoint))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var accountBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Account Breakdown")
            
            adaptiveCard {
                if accounts.isEmpty {
                    emptyState(
                        title: "No accounts yet",
                        subtitle: "Add an account to see what makes up your total balance.",
                        systemImage: "wallet.pass"
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(accounts.sorted { abs($0.accountBalance) > abs($1.accountBalance) }.enumerated()), id: \.element.id) { index, account in
                            accountBreakdownRow(for: account)
                            
                            if index < accounts.count - 1 {
                                Divider()
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func accountBreakdownRow(for account: Account) -> some View {
        let share = accountShare(for: account)
        
        return HStack(spacing: 14) {
            Circle()
                .fill(accountTint(for: account).opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: account.iconName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(accountTint(for: account))
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(account.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(account.accountBalance, format: .currency(code: "BDT"))
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
                            .fill(accountTint(for: account))
                            .frame(width: max(8, proxy.size.width * share))
                    }
                }
                .frame(height: 6)
                
                Text("\((share * 100).formatted(.number.precision(.fractionLength(0))))% of tracked balance")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 12)
    }
    
    private func compactMovementRow(for transaction: Transaction) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(transactionTint(for: transaction).opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: transactionIcon(for: transaction))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(transactionTint(for: transaction))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transactionTitle(for: transaction))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                
                Text(transaction.accountName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            Text(transaction.amount, format: .currency(code: "BDT"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.transactionType == .income ? positiveColor : negativeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 9)
    }
    
    private func dateField(title: String, date: Binding<Date>, range: PartialRangeThrough<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            
            DatePicker(title, selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func dateField(title: String, date: Binding<Date>, range: ClosedRange<Date>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            
            DatePicker(title, selection: date, in: range, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

private extension BalanceTrendView {
    enum BalancePeriod: String, CaseIterable, Identifiable {
        case oneWeek
        case oneMonth
        case threeMonths
        case sixMonths
        case oneYear
        case all
        case custom
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .oneWeek: return "1W"
            case .oneMonth: return "1M"
            case .threeMonths: return "3M"
            case .sixMonths: return "6M"
            case .oneYear: return "1Y"
            case .all: return "All"
            case .custom: return "Custom"
            }
        }
        
        var description: String {
            switch self {
            case .oneWeek: return "Last 7 days"
            case .oneMonth: return "Last month"
            case .threeMonths: return "Last 3 months"
            case .sixMonths: return "Last 6 months"
            case .oneYear: return "Last year"
            case .all: return "All time"
            case .custom: return "Custom period"
            }
        }
        
        func startDate(from referenceDate: Date, earliestDate: Date?, customStartDate: Date) -> Date {
            let calendar = Calendar.current
            
            switch self {
            case .oneWeek:
                return calendar.date(byAdding: .day, value: -6, to: referenceDate) ?? referenceDate
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
            case .custom:
                return customStartDate
            }
        }
    }
    
    struct BalancePoint: Identifiable, Equatable {
        let date: Date
        let balance: Double
        
        var id: Date { date }
    }
    
    var allTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.accountBalance }
    }
    
    var chartLowerBound: Double {
        let minimum = chartPoints.map(\.balance).min() ?? 0
        let maximum = chartPoints.map(\.balance).max() ?? 1
        let padding = max((maximum - minimum) * 0.12, 100)
        return minimum - padding
    }
    
    var chartUpperBound: Double {
        let minimum = chartPoints.map(\.balance).min() ?? 0
        let maximum = chartPoints.map(\.balance).max() ?? 1
        let padding = max((maximum - minimum) * 0.12, 100)
        return maximum + padding
    }
    
    var periodBalanceChange: Double {
        guard let first = chartPoints.first, let last = chartPoints.last else {
            return 0
        }
        
        return last.balance - first.balance
    }
    
    var periodChangeDescription: String {
        let amount = periodBalanceChange.formatted(.currency(code: "BDT"))
        
        if periodBalanceChange == 0 {
            return "No balance change in \(periodDescriptionForSentence)"
        }
        
        return "\(amount) in \(periodDescriptionForSentence)"
    }
    
    var periodDescriptionForSentence: String {
        selectedPeriod == .custom ? customPeriodDescription : selectedPeriod.description.lowercased()
    }
    
    var customPeriodDescription: String {
        let start = Calendar.current.startOfDay(for: customStartDate)
        let end = Calendar.current.startOfDay(for: customEndDate)
        
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formattedPickerDate(start)
        }
        
        return "\(formattedPickerDate(start)) - \(formattedPickerDate(end))"
    }
    
    var selectedTransactions: [Transaction] {
        let calendar = Calendar.current
        
        if let selectedPoint {
            return balanceChangingTransactions.filter {
                calendar.isDate($0.date, inSameDayAs: selectedPoint.date)
            }
        }
        
        guard let start = dateRange.first, let end = dateRange.last else {
            return []
        }
        
        let endOfRange = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: end) ?? end
        return balanceChangingTransactions.filter { transaction in
            transaction.date >= start && transaction.date <= endOfRange
        }
    }
    
    var displayedMovementTransactions: [Transaction] {
        Array(selectedTransactions.sorted { $0.date > $1.date }.prefix(movementDisplayLimit))
    }
    
    var movementDisplayLimit: Int {
        6
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
    
    var chartColor: Color {
        colorScheme == .dark ? Color(hex: "#7ADDB9") : Color(hex: "#1F8F63")
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
    
    func nearestPoint(to date: Date) -> BalancePoint? {
        chartPoints.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }
    
    func pointChangeDescription(for point: BalancePoint) -> String {
        guard let index = chartPoints.firstIndex(of: point), index > 0 else {
            return "Starting point for this period"
        }
        
        let previousBalance = chartPoints[index - 1].balance
        let change = point.balance - previousBalance
        
        if change == 0 {
            return "No change from previous point"
        }
        
        let direction = change > 0 ? "up" : "down"
        return "\(direction.capitalized) \(abs(change).formatted(.currency(code: "BDT"))) from previous point"
    }
    
    func accountShare(for account: Account) -> Double {
        let totalTrackedBalance = accounts.reduce(0) { $0 + abs($1.accountBalance) }
        
        guard totalTrackedBalance > 0 else {
            return 0
        }
        
        return min(abs(account.accountBalance) / totalTrackedBalance, 1)
    }
    
    func accountTint(for account: Account) -> Color {
        account.accountType == .credit ? Color(hex: "#F5A623") : Color(hex: "#28B36E")
    }
    
    func transactionTitle(for transaction: Transaction) -> String {
        transaction.category.isEmpty ? transaction.transactionType.description : transaction.category
    }
    
    func transactionIcon(for transaction: Transaction) -> String {
        transaction.transactionCategory?.icon ?? (transaction.transactionType == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
    }
    
    func transactionTint(for transaction: Transaction) -> Color {
        switch transaction.transactionType {
        case .income:
            return positiveColor
        case .expense:
            return transaction.transactionCategory?.color ?? negativeColor
        case .transfer:
            return Color(hex: "#5B5CEB")
        }
    }
    
    func axisLabel(for date: Date) -> String {
        switch selectedPeriod {
        case .oneWeek, .oneMonth:
            return date.formatted(.dateTime.day().month(.abbreviated))
        case .threeMonths, .sixMonths, .oneYear, .all, .custom:
            return date.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
        }
    }
    
    func formattedPickerDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
    }
    
    func compactCurrency(_ amount: Double) -> String {
        let absoluteAmount = abs(amount)
        let sign = amount < 0 ? "-" : ""
        
        switch absoluteAmount {
        case 1_000_000...:
            return "\(sign)৳\((absoluteAmount / 1_000_000).formatted(.number.precision(.fractionLength(1))))M"
        case 1_000...:
            return "\(sign)৳\((absoluteAmount / 1_000).formatted(.number.precision(.fractionLength(0))))K"
        default:
            return amount.formatted(.currency(code: "BDT").precision(.fractionLength(0)))
        }
    }
}
