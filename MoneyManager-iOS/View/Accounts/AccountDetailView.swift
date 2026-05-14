//
//  AccountDetailView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 14/5/26.
//

import Charts
import SwiftData
import SwiftUI

struct AccountDetailView: View {
    @Environment(HomeTabView.Router.self) private var router
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    @State private var selectedPeriod: AccountDetailPeriod = .oneMonth
    @State private var selectedPoint: AccountBalancePoint?
    @State private var presentAddTransactionSheet = false
    @State private var addTransactionType: Transaction.TransactionType = .expense
    @State private var transactionPendingDeletion: Transaction?
    @State private var transactionPendingEdit: Transaction?
    @State private var rowOffsets: [String: CGFloat] = [:]
    
    let accountID: String
    
    var body: some View {
        Group {
            if let account {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection(for: account)
                        quickActionsSection(for: account)
                        periodPicker
                        balanceChartSection(for: account)
                        summarySection(for: account)
                        
                        if account.accountType == .credit {
                            creditSection(for: account)
                        }
                        
                        recentActivitySection(for: account)
                        accountInfoSection(for: account)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .background(screenBackground.ignoresSafeArea())
                .navigationTitle(account.name)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $presentAddTransactionSheet) {
                    TransactionTabView(
                        initialTransactionType: addTransactionType,
                        initialAccount: account
                    )
                    .presentationDetents([.large])
                }
                .sheet(item: $transactionPendingEdit) { transaction in
                    TransactionTabView(editingTransaction: transaction)
                        .presentationDetents([.large])
                }
                .alert("Delete transaction?", isPresented: deleteAlertBinding, presenting: transactionPendingDeletion) { transaction in
                    Button("Delete", role: .destructive) {
                        deleteTransaction(transaction)
                    }
                    Button("Cancel", role: .cancel) {
                        transactionPendingDeletion = nil
                    }
                } message: { transaction in
                    Text("This will remove \(transactionTitle(for: transaction, in: account)) and update the account balance.")
                }
                .onChange(of: selectedPeriod) { _, _ in
                    selectedPoint = chartPoints(for: account).last
                }
                .onAppear {
                    selectedPoint = chartPoints(for: account).last
                }
            } else {
                emptyMissingAccountView
            }
        }
    }
    
    private func headerSection(for account: Account) -> some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    Circle()
                        .fill(accountTint(for: account).opacity(colorScheme == .dark ? 0.20 : 0.12))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: accountSymbol(for: account))
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(accountTint(for: account))
                        }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(account.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text(accountSubtitle(for: account))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer(minLength: 0)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(account.accountType == .credit ? "Outstanding Balance" : "Current Balance")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(account.accountBalance, format: .currency(code: "BDT"))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                    
                    HStack(spacing: 8) {
                        Image(systemName: periodChange(for: account) >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 13, weight: .bold))
                        
                        Text(periodChangeDescription(for: account))
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(periodChange(for: account) >= 0 ? positiveColor : negativeColor)
                }
            }
        }
    }
    
    private func quickActionsSection(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Quick Actions")
            
            adaptiveCard {
                HStack(spacing: 0) {
                    quickActionItem(title: "Expense", systemImage: "plus", tint: negativeColor) {
                        openAddTransaction(.expense)
                    }
                    
                    quickActionDivider
                    
                    quickActionItem(title: "Income", systemImage: "plus", tint: positiveColor) {
                        openAddTransaction(.income)
                    }
                    
                    quickActionDivider
                    
                    quickActionItem(title: "Transfer", systemImage: "arrow.left.arrow.right", tint: transferColor) {
                        openAddTransaction(.transfer)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(AccountDetailPeriod.allCases) { period in
                Text(period.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .font(.system(size: 11, weight: .semibold))
    }
    
    private func balanceChartSection(for account: Account) -> some View {
        let points = chartPoints(for: account)
        
        return adaptiveCard {
            VStack(alignment: .leading, spacing: 16) {
                selectedPointHeader(for: account, points: points)
                
                if points.count > 1 {
                    Chart {
                        ForEach(points) { point in
                            AreaMark(
                                x: .value("Date", point.date),
                                yStart: .value("Baseline", chartBounds(for: points).lower),
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
                            .interpolationMethod(.catmullRom)
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
                    .frame(height: 230)
                    .chartLegend(.hidden)
                    .chartYScale(domain: chartBounds(for: points).lower...chartBounds(for: points).upper)
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
                                            
                                            selectedPoint = nearestPoint(to: date, in: points)
                                        }
                                )
                        }
                    }
                } else {
                    emptyState(
                        title: "No balance history yet",
                        subtitle: "Add activity in this account to see its movement.",
                        systemImage: "chart.xyaxis.line"
                    )
                }
            }
        }
    }
    
    private func summarySection(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Period Summary")
            
            LazyVGrid(columns: summaryColumns, spacing: 10) {
                metricCard(title: "Income", amount: periodIncome(for: account), systemImage: "arrow.down", tint: positiveColor)
                metricCard(title: "Expense", amount: periodExpense(for: account), systemImage: "arrow.up", tint: negativeColor)
                metricCard(title: "Transfers In", amount: periodTransfersIn(for: account), systemImage: "arrow.down.left", tint: transferColor)
                metricCard(title: "Transfers Out", amount: periodTransfersOut(for: account), systemImage: "arrow.up.right", tint: transferColor)
            }
        }
    }
    
    private func creditSection(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Credit Snapshot")
            
            adaptiveCard {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        creditMetric(title: "Used", amount: creditUsed(for: account), tint: negativeColor)
                        creditMetric(title: "Available", amount: creditAvailable(for: account), tint: positiveColor)
                    }
                    
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.07))
                            
                            Capsule(style: .continuous)
                                .fill(creditUsageRatio(for: account) > 0.8 ? negativeColor : accountTint(for: account))
                                .frame(width: max(8, proxy.size.width * creditUsageRatio(for: account)))
                        }
                    }
                    .frame(height: 8)
                    
                    HStack(spacing: 12) {
                        infoPill(title: "Limit", value: account.accountCreditLimit.formatted(.currency(code: "BDT")))
                        infoPill(title: "Due", value: dueDateDescription(for: account))
                    }
                }
            }
        }
    }
    
    private func recentActivitySection(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading("Recent Activity")
                Spacer()
                
                if accountTransactions(for: account).count > recentTransactionLimit {
                    Button {
                        router.navigate(to: .accountTransactionsView(accountID: account.id))
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
                }
            }
            
            adaptiveCard {
                let transactions = Array(accountTransactions(for: account).prefix(recentTransactionLimit))
                
                if transactions.isEmpty {
                    emptyState(
                        title: "No transactions yet",
                        subtitle: "Income, expenses, and transfers for this account will appear here.",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                            swipeableTransactionRow(for: transaction, in: account)
                            
                            if index < transactions.count - 1 {
                                Divider()
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func accountInfoSection(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Account Info")
            
            adaptiveCard {
                VStack(spacing: 0) {
                    infoRow(title: "Type", value: account.accountType.description, systemImage: accountSymbol(for: account), tint: accountTint(for: account))
                    Divider().padding(.leading, 42)
                    infoRow(title: "Currency", value: "BDT", systemImage: "banknote", tint: Color(hex: "#3C9BFF"))
                    
                    if account.accountType == .credit {
                        Divider().padding(.leading, 42)
                        infoRow(title: "Billing Day", value: dayDescription(account.accountBillingDay), systemImage: "calendar", tint: Color(hex: "#8A63FF"))
                        Divider().padding(.leading, 42)
                        infoRow(title: "Due Day", value: dayDescription(account.accountDueDay), systemImage: "calendar.badge.clock", tint: negativeColor)
                    }
                }
            }
        }
    }
}

private extension AccountDetailView {
    enum AccountDetailPeriod: String, CaseIterable, Identifiable {
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
            case .oneMonth: return "this month"
            case .threeMonths: return "last 3 months"
            case .sixMonths: return "last 6 months"
            case .oneYear: return "this year"
            case .all: return "all time"
            }
        }
        
        func startDate(from referenceDate: Date, earliestDate: Date?) -> Date {
            let calendar = Calendar.current
            
            switch self {
            case .oneMonth:
                return calendar.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: referenceDate) ?? referenceDate
            case .sixMonths:
                return calendar.date(byAdding: .month, value: -6, to: referenceDate) ?? referenceDate
            case .oneYear:
                return calendar.dateInterval(of: .year, for: referenceDate)?.start ?? referenceDate
            case .all:
                return earliestDate ?? calendar.date(byAdding: .month, value: -1, to: referenceDate) ?? referenceDate
            }
        }
    }
    
    struct AccountBalancePoint: Identifiable, Equatable {
        let date: Date
        let balance: Double
        
        var id: Date { date }
    }
    
    var account: Account? {
        accounts.first { $0.id == accountID }
    }
    
    var recentTransactionLimit: Int {
        5
    }
    
    var summaryColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
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
    
    var transferColor: Color {
        Color(hex: "#5B5CEB")
    }
    
    var emptyMissingAccountView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text("Account not found")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(primaryTextColor)
            
            Text("This account may have been removed.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func openAddTransaction(_ type: Transaction.TransactionType) {
        addTransactionType = type
        presentAddTransactionSheet = true
    }
    
    func accountTransactions(for account: Account) -> [Transaction] {
        account.transactions
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }
    
    func periodTransactions(for account: Account) -> [Transaction] {
        let calendar = Calendar.current
        let range = dateRange(for: account)
        guard let start = range.first, let end = range.last else {
            return []
        }
        
        let endOfRange = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: end) ?? end
        return accountTransactions(for: account).filter { $0.date >= start && $0.date <= endOfRange }
    }
    
    func dateRange(for account: Account) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let earliestDate = accountTransactions(for: account).map(\.date).min().map { calendar.startOfDay(for: $0) }
        let start = calendar.startOfDay(for: selectedPeriod.startDate(from: today, earliestDate: earliestDate))
        
        var dates: [Date] = []
        var currentDate = min(start, today)
        
        while currentDate <= today {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates.isEmpty ? [today] : dates
    }
    
    func chartPoints(for account: Account) -> [AccountBalancePoint] {
        let transactions = accountTransactions(for: account)
        return dateRange(for: account).map { date in
            AccountBalancePoint(
                date: date,
                balance: accountBalance(atEndOf: date, account: account, transactions: transactions)
            )
        }
    }
    
    func accountBalance(atEndOf date: Date, account: Account, transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: date)) ?? date
        let laterImpact = transactions
            .filter { $0.date > endOfDay }
            .reduce(0) { $0 + accountImpact(of: $1, for: account) }
        
        return account.accountBalance - laterImpact
    }
    
    func accountImpact(of transaction: Transaction, for account: Account) -> Double {
        guard transaction.transactionType == .transfer else {
            return transaction.account == account ? transaction.amount : 0
        }
        
        if transaction.account == account {
            return -transaction.amount
        }
        
        if transaction.transferAccount == account {
            return transaction.amount
        }
        
        return 0
    }
    
    func chartBounds(for points: [AccountBalancePoint]) -> (lower: Double, upper: Double) {
        let minimum = points.map(\.balance).min() ?? 0
        let maximum = points.map(\.balance).max() ?? 1
        let padding = max((maximum - minimum) * 0.12, 100)
        return (minimum - padding, maximum + padding)
    }
    
    func periodChange(for account: Account) -> Double {
        let points = chartPoints(for: account)
        guard let first = points.first, let last = points.last else {
            return 0
        }
        
        return last.balance - first.balance
    }
    
    func periodChangeDescription(for account: Account) -> String {
        let change = periodChange(for: account)
        
        if change == 0 {
            return "No balance change in \(selectedPeriod.description)"
        }
        
        return "\(change.formatted(.currency(code: "BDT"))) in \(selectedPeriod.description)"
    }

    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { transactionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    transactionPendingDeletion = nil
                }
            }
        )
    }

    func deleteTransaction(_ transaction: Transaction) {
        transaction.delete(in: modelContext)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete transaction: \(error)")
        }
        transactionPendingDeletion = nil
        rowOffsets[transaction.id] = 0
    }
    
    func periodIncome(for account: Account) -> Double {
        periodTransactions(for: account)
            .filter { $0.transactionType == .income && $0.account == account }
            .reduce(0) { $0 + $1.amount }
    }
    
    func periodExpense(for account: Account) -> Double {
        abs(
            periodTransactions(for: account)
                .filter { $0.transactionType == .expense && $0.account == account }
                .reduce(0) { $0 + $1.amount }
        )
    }
    
    func periodTransfersIn(for account: Account) -> Double {
        periodTransactions(for: account)
            .filter { $0.transactionType == .transfer && $0.transferAccount == account }
            .reduce(0) { $0 + $1.amount }
    }
    
    func periodTransfersOut(for account: Account) -> Double {
        periodTransactions(for: account)
            .filter { $0.transactionType == .transfer && $0.account == account }
            .reduce(0) { $0 + $1.amount }
    }
    
    func nearestPoint(to date: Date, in points: [AccountBalancePoint]) -> AccountBalancePoint? {
        points.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }
    
    func selectedPointHeader(for account: Account, points: [AccountBalancePoint]) -> some View {
        let activePoint = selectedPoint ?? points.last
        
        return HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(chartColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(chartColor)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activePoint?.date.formatted(date: .abbreviated, time: .omitted) ?? selectedPeriod.description.capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text((activePoint?.balance ?? account.accountBalance), format: .currency(code: "BDT"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    func metricCard(title: String, amount: Double, systemImage: String, tint: Color) -> some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 10) {
                Circle()
                    .fill(tint.opacity(colorScheme == .dark ? 0.18 : 0.12))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(amount, format: .currency(code: "BDT"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        }
    }
    
    func creditMetric(title: String, amount: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(amount, format: .currency(code: "BDT"))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func transactionRow(for transaction: Transaction, in account: Account) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(transactionTint(for: transaction, in: account).opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: transactionIcon(for: transaction))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(transactionTint(for: transaction, in: account))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transactionTitle(for: transaction, in: account))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 6) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(transaction.transactionType.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(transactionTint(for: transaction, in: account))
                }
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            Text(accountImpact(of: transaction, for: account), format: .currency(code: "BDT"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(transactionTint(for: transaction, in: account))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
    }

    func swipeableTransactionRow(for transaction: Transaction, in account: Account) -> some View {
        let offset = rowOffsets[transaction.id] ?? 0
        
        return ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                transactionPendingDeletion = transaction
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 82)
                    .frame(maxHeight: .infinity)
                    .background(negativeColor)
            }
            .buttonStyle(.plain)
            .opacity(offset < -8 ? 1 : 0)
            
            transactionRow(for: transaction, in: account)
                .padding(.horizontal, 16)
                .background(cardBackground)
                .offset(x: offset)
                .contentShape(Rectangle())
                .onTapGesture {
                    if offset < -8 {
                        rowOffsets[transaction.id] = 0
                    } else {
                        transactionPendingEdit = transaction
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 18)
                        .onChanged { value in
                            let currentOffset = rowOffsets[transaction.id] ?? 0
                            let proposedOffset = value.translation.width < 0
                                ? value.translation.width
                                : currentOffset + value.translation.width
                            
                            rowOffsets[transaction.id] = min(0, max(-82, proposedOffset))
                        }
                        .onEnded { _ in
                            let finalOffset = rowOffsets[transaction.id] ?? 0
                            rowOffsets[transaction.id] = finalOffset < -40 ? -82 : 0
                        }
                )
                .animation(.snappy(duration: 0.2), value: offset)
        }
        .padding(.horizontal, -16)
        .clipped()
    }
    
    func quickActionItem(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Circle()
                    .fill(tint.opacity(colorScheme == .dark ? 0.18 : 0.12))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: systemImage)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                
                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    var quickActionDivider: some View {
        Rectangle()
            .fill(cardStrokeColor)
            .frame(width: 1, height: 34)
    }
    
    func infoRow(title: String, value: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            rowIcon(systemName: systemImage, color: tint)
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(primaryTextColor)
            
            Spacer(minLength: 8)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
    }
    
    func infoPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(primaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    func rowIcon(systemName: String, color: Color) -> some View {
        Circle()
            .fill(color.opacity(colorScheme == .dark ? 0.18 : 0.12))
            .frame(width: 32, height: 32)
            .overlay {
                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
            }
    }
    
    func adaptiveCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
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
    
    func emptyState(title: String, subtitle: String, systemImage: String) -> some View {
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
    
    func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(primaryTextColor)
    }
    
    func accountTint(for account: Account) -> Color {
        account.accountType == .credit ? Color(hex: "#F5A623") : Color(hex: "#28B36E")
    }
    
    func accountSymbol(for account: Account) -> String {
        if account.accountType == .credit {
            return "creditcard.fill"
        }
        
        if account.name.localizedCaseInsensitiveContains("cash") {
            return "wallet.pass.fill"
        }
        
        return "building.columns.fill"
    }
    
    func accountSubtitle(for account: Account) -> String {
        if account.accountType == .credit {
            return "Credit Account"
        }
        
        if account.name.localizedCaseInsensitiveContains("cash") {
            return "Cash Wallet"
        }
        
        return "Debit Account"
    }
    
    func transactionTitle(for transaction: Transaction, in account: Account) -> String {
        if transaction.transactionType == .transfer {
            if transaction.account == account {
                return "Transfer to \(transaction.transferAccountName)"
            }
            
            return "Transfer from \(transaction.accountName)"
        }
        
        return transaction.category.isEmpty ? transaction.transactionType.description : transaction.category
    }
    
    func transactionIcon(for transaction: Transaction) -> String {
        if transaction.transactionType == .transfer {
            return "arrow.left.arrow.right"
        }
        
        return transaction.transactionCategory?.icon ?? (transaction.transactionType == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
    }
    
    func transactionTint(for transaction: Transaction, in account: Account) -> Color {
        if transaction.transactionType == .transfer {
            return accountImpact(of: transaction, for: account) >= 0 ? positiveColor : transferColor
        }
        
        switch transaction.transactionType {
        case .income:
            return positiveColor
        case .expense:
            return transaction.transactionCategory?.color ?? negativeColor
        case .transfer:
            return transferColor
        }
    }
    
    func creditUsed(for account: Account) -> Double {
        max(0, -account.accountBalance)
    }
    
    func creditAvailable(for account: Account) -> Double {
        max(0, account.accountCreditLimit - creditUsed(for: account))
    }
    
    func creditUsageRatio(for account: Account) -> Double {
        guard account.accountCreditLimit > 0 else {
            return 0
        }
        
        return min(creditUsed(for: account) / account.accountCreditLimit, 1)
    }
    
    func dueDateDescription(for account: Account) -> String {
        guard account.accountDueDay > 0 else {
            return "Not set"
        }
        
        return dayDescription(account.accountDueDay)
    }
    
    func dayDescription(_ day: Int) -> String {
        guard day > 0 else {
            return "Not set"
        }
        
        return "Day \(day)"
    }
    
    func axisLabel(for date: Date) -> String {
        switch selectedPeriod {
        case .oneMonth:
            return date.formatted(.dateTime.day().month(.abbreviated))
        case .threeMonths, .sixMonths, .oneYear, .all:
            return date.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
        }
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
