//
//  HomeView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import Charts
import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(HomeTabView.Router.self) private var router
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    @State private var presentAddAccountView = false
    
    let openAddTransaction: (Transaction.TransactionType) -> Void
    
    init(openAddTransaction: @escaping (Transaction.TransactionType) -> Void = { _ in }) {
        self.openAddTransaction = openAddTransaction
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                headerSection
                balanceCard
                statCardsSection
                quickActionsSection
                spendingOverviewSection
                accountsSection
                recentTransactionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentAddAccountView) {
            NavigationStack {
                AddAccountView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Home")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor)
            
            Text("Your finance at a glance")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var balanceCard: some View {
        Button {
            router.navigate(to: .balanceDetailsView)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(balanceGradient)
                    .overlay(alignment: .trailing) {
                        balanceArtwork
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(.white.opacity(colorScheme == .dark ? 0.06 : 0.14), lineWidth: 1)
                    }
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Text("Total Balance")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.96))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(totalBalance.formatted(.currency(code: "BDT")))
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .contentTransition(.numericText())
                        
                        HStack(spacing: 8) {
                            Image(systemName: balanceTrendDelta >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12, weight: .bold))
                            
                            Text(balanceTrendDescription)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                        }
                        .foregroundStyle(.white.opacity(0.88))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 104)
                }
                .padding(22)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View balance details")
        .frame(maxWidth: .infinity)
        .frame(height: 164)
        .shadow(color: shadowColor, radius: 20, y: 10)
    }
    
    private var statCardsSection: some View {
        LazyVGrid(columns: statColumns, spacing: 10) {
            summaryCard(
                title: "Income",
                amount: monthlyIncome,
                caption: "This Month",
                systemImage: "arrow.down",
                tint: Color(hex: "#1FB56B")
            )
            
            summaryCard(
                title: "Expense",
                amount: monthlyExpense,
                caption: "This Month",
                systemImage: "arrow.up",
                tint: Color(hex: "#FF5C54")
            )
            
            summaryCard(
                title: "Net Savings",
                amount: monthlySavings,
                caption: "This Month",
                systemImage: "chart.line.uptrend.xyaxis",
                tint: Color(hex: "#5B5CEB")
            )
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: "Quick Actions")
            
            adaptiveCard {
                HStack(spacing: 0) {
                    quickActionItem(title: "Add Expense", systemImage: "plus", tint: Color(hex: "#26B86A")) {
                        openAddTransaction(.expense)
                    }
                    
                    quickActionDivider
                    
                    quickActionItem(title: "Add Income", systemImage: "plus", tint: Color(hex: "#3C9BFF")) {
                        openAddTransaction(.income)
                    }
                    
                    quickActionDivider
                    
                    quickActionItem(title: "Transfer", systemImage: "arrow.left.arrow.right", tint: Color(hex: "#8A63FF")) {
                        openAddTransaction(.transfer)
                    }
                    
                    quickActionDivider
                    
                    quickActionItem(title: "Add Account", systemImage: "doc.text", tint: Color(hex: "#F5A623")) {
                        presentAddAccountView = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var spendingOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading(title: "Spending Overview")
                Spacer()
                Text(monthLabel)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            adaptiveCard {
                if monthlyExpense > 0 {
                    Chart {
                        ForEach(nonZeroMonthlyExpenseByDay) { item in
                            BarMark(
                                x: .value("Day", item.day),
                                y: .value("Expense", item.amount)
                            )
                            .foregroundStyle(chartBarColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            
                            if item.id == highestExpenseDay?.id {
                                PointMark(
                                    x: .value("Day", item.day),
                                    y: .value("Expense", item.amount)
                                )
                                .annotation(position: .top, spacing: 12) {
                                    Text(item.amount, format: .currency(code: "BDT"))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(chartHighlightColor)
                                        )
                                }
                            }
                        }
                    }
                    .frame(height: 180)
                    .chartLegend(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 6]))
                                .foregroundStyle(chartGridColor)
                            AxisValueLabel()
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: monthlyExpenseAxisMarks) { value in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    Text("\(day)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    emptyCardState(
                        title: "No spending this month",
                        subtitle: "Your monthly expense chart will appear after you log some expenses.",
                        systemImage: "chart.bar.xaxis"
                    )
                }
            }
        }
    }
    
    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading(title: "Accounts")
                Spacer()
                
                if accounts.count > 3 {
                    sectionLinkButton(title: "Update") {
                        router.navigate(to: .accountsView)
                    }
                }
            }
            
            if accounts.isEmpty {
                adaptiveCard {
                    emptyCardState(
                        title: "No accounts yet",
                        subtitle: "Add an account to start tracking balances and transactions.",
                        systemImage: "wallet.pass"
                    )
                }
            } else {
                LazyVGrid(columns: accountColumns, spacing: accountCardSpacing) {
                    ForEach(accounts) { account in
                        accountCard(for: account)
                    }
                }
            }
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading(title: "Recent Transactions")
                Spacer()
                
                if !recentTransactions.isEmpty {
                    sectionLinkButton(title: "View All") {
                        router.navigate(to: .allTransactionsView)
                    }
                }
            }
            
            adaptiveCard {
                if recentTransactions.isEmpty {
                    emptyCardState(
                        title: "No transactions yet",
                        subtitle: "Your recent transactions will appear here once you add them.",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                            transactionRow(for: transaction)
                            
                            if index < recentTransactions.count - 1 {
                                Divider()
                                    .padding(.leading, 74)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var balanceArtwork: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 148, height: 148)
                .offset(x: 48, y: -44)
            
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.08))
                .frame(width: 88, height: 88)
                .offset(x: 10, y: 24)
            
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white.opacity(0.92))
                .offset(x: 10, y: 24)
        }
        .frame(width: 180, height: 164, alignment: .trailing)
        .clipped()
    }
    
    private func summaryCard(
        title: String,
        amount: Double,
        caption: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        adaptiveCard {
            VStack(alignment: .leading, spacing: 10) {
                Circle()
                    .fill(tint.opacity(colorScheme == .dark ? 0.18 : 0.10))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(amount, format: .currency(code: "BDT"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        }
    }
    
    private func quickActionItem(
        title: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
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
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var quickActionDivider: some View {
        Rectangle()
            .fill(cardStrokeColor)
            .frame(width: 1, height: 34)
    }
    
    private func accountCard(for account: Account) -> some View {
        adaptiveCard {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(accountTint(for: account).opacity(colorScheme == .dark ? 0.18 : 0.12))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: accountSymbol(for: account))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(accountTint(for: account))
                    }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(accountCardTitle(for: account))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(account.accountBalance, format: .currency(code: "BDT"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Text(accountSubtitle(for: account))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        }
    }
    
    private func transactionRow(for transaction: Transaction) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(transactionTint(for: transaction).opacity(colorScheme == .dark ? 0.18 : 0.12))
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
                
                HStack(spacing: 6) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(transactionTypeLabel(for: transaction))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(transaction.transactionType.color)
                }
            }
            .layoutPriority(1)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(transaction.amount, format: .currency(code: "BDT"))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(transaction.transactionType.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 12)
    }
    
    private func sectionHeading(title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(primaryTextColor)
    }
    
    private func sectionLinkButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
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
    
    private func emptyCardState(title: String, subtitle: String, systemImage: String) -> some View {
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

private extension HomeView {
    struct DailyExpense: Identifiable {
        let day: Int
        let amount: Double
        
        var id: Int { day }
    }
    
    var allTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }
    
    var recentTransactions: [Transaction] {
        Array(allTransactions.prefix(4))
    }
    
    var featuredAccounts: [Account] {
        Array(accounts.sorted { abs($0.accountBalance) > abs($1.accountBalance) }.prefix(3))
    }
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.accountBalance }
    }
    
    var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        return allTransactions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }
    
    var previousMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }
        
        return allTransactions.filter { calendar.isDate($0.date, equalTo: previousMonthDate, toGranularity: .month) }
    }
    
    var monthlyIncome: Double {
        currentMonthTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpense: Double {
        abs(
            currentMonthTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
    }
    
    var monthlySavings: Double {
        monthlyIncome - monthlyExpense
    }
    
    var previousMonthSavings: Double {
        let income = previousMonthTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        let expense = abs(
            previousMonthTransactions
                .filter { $0.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
        
        return income - expense
    }
    
    var balanceTrendDelta: Double {
        monthlySavings - previousMonthSavings
    }
    
    var balanceTrendDescription: String {
        guard !previousMonthTransactions.isEmpty else {
            return "Add more history to compare with last month"
        }
        
        guard previousMonthSavings != 0 else {
            return balanceTrendDelta == 0
                ? "Unchanged from last month"
                : "\(balanceTrendDelta.formatted(.currency(code: "BDT"))) versus last month"
        }
        
        let percentage = abs((balanceTrendDelta / previousMonthSavings) * 100)
        return "\(percentage.formatted(.number.precision(.fractionLength(1))))% from last month"
    }
    
    var monthLabel: String {
        "This Month"
    }
    
    var monthlyExpenseByDay: [DailyExpense] {
        let calendar = Calendar.current
        let expenseByDay = Dictionary(grouping: currentMonthTransactions.filter { $0.transactionType == .expense }) {
            calendar.component(.day, from: $0.date)
        }
        
        guard let days = calendar.range(of: .day, in: .month, for: Date()) else {
            return []
        }
        
        return days.map { day in
            let amount = abs((expenseByDay[day] ?? []).reduce(0) { $0 + $1.amount })
            return DailyExpense(day: day, amount: amount)
        }
    }
    
    var nonZeroMonthlyExpenseByDay: [DailyExpense] {
        monthlyExpenseByDay.filter { $0.amount > 0 }
    }
    
    var highestExpenseDay: DailyExpense? {
        nonZeroMonthlyExpenseByDay.max { $0.amount < $1.amount }
    }
    
    var monthlyExpenseAxisMarks: [Int] {
        let days = monthlyExpenseByDay.map(\.day)
        guard let lastDay = days.last else {
            return []
        }
        
        var marks = Array(stride(from: 1, through: lastDay, by: 5))
        if marks.last != lastDay {
            marks.append(lastDay)
        }
        return marks
    }
    
    var accountCardSpacing: CGFloat {
        14
    }
    
    var accountColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: accountCardSpacing),
            GridItem(.flexible(), spacing: accountCardSpacing)
        ]
    }
    
    var statColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
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
    
    var balanceGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(hex: "#0F5D4F"), Color(hex: "#136959"), Color(hex: "#1B7A67")]
                : [Color(hex: "#156C60"), Color(hex: "#1A7565"), Color(hex: "#2D8571")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var chartBarColor: Color {
        colorScheme == .dark ? Color(hex: "#6BE2B5") : Color(hex: "#A9EBCF")
    }
    
    var chartHighlightColor: Color {
        colorScheme == .dark ? Color(hex: "#1F8F63") : Color(hex: "#2DA672")
    }
    
    var chartGridColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.08)
    }
    
    func accountTint(for account: Account) -> Color {
        account.accountType == .credit ? Color(hex: "#F5A623") : Color(hex: "#28B36E")
    }
    
    func accountCardTitle(for account: Account) -> String {
        if account.accountType == .credit {
            return "Credit Card"
        }
        
        if account.name.localizedCaseInsensitiveContains("cash") {
            return "Cash Wallet"
        }
        
        return account.name
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
            return "Credit"
        }
        
        if account.name.localizedCaseInsensitiveContains("cash") {
            return "Cash"
        }
        
        return "Bank"
    }
    
    func transactionTitle(for transaction: Transaction) -> String {
        if transaction.transactionType == .transfer {
            return "Transfer"
        }
        
        return transaction.category
    }
    
    func transactionTypeLabel(for transaction: Transaction) -> String {
        transaction.transactionType.description
    }
    
    func transactionIcon(for transaction: Transaction) -> String {
        if transaction.transactionType == .transfer {
            return "arrow.left.arrow.right"
        }
        
        return transaction.transactionCategory?.icon ?? "dollarsign.circle"
    }
    
    func transactionTint(for transaction: Transaction) -> Color {
        if transaction.transactionType == .transfer {
            return Color(hex: "#8A63FF")
        }
        
        switch transaction.transactionType {
        case .expense:
            return transaction.transactionCategory?.color ?? Color(hex: "#FF8A4C")
        case .income:
            return Color(hex: "#1FB56B")
        case .transfer:
            return Color(hex: "#8A63FF")
        }
    }
}
