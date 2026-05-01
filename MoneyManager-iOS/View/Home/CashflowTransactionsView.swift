//
//  CashflowTransactionsView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 29/4/26.
//

import SwiftData
import SwiftUI

struct CashflowTransactionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    @State private var searchString = ""
    
    let metric: CashflowMetric
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                headerSection
                
                if datewiseTransactions.isEmpty {
                    adaptiveCard {
                        emptyState(
                            title: "No matching transactions",
                            subtitle: "Try changing your search or add more income and expense entries.",
                            systemImage: "tray"
                        )
                    }
                } else {
                    ForEach(sortedTransactionDates, id: \.self) { date in
                        transactionDateSection(date)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchString)
    }
    
    private var headerSection: some View {
        adaptiveCard {
            HStack(spacing: 12) {
                Circle()
                    .fill(metric.tint.opacity(colorScheme == .dark ? 0.20 : 0.12))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: metric.symbolName)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(metric.tint)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(metricAmount, format: .currency(code: "BDT"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    Text(monthRangeDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private func transactionDateSection(_ date: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(date, style: .date)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)
            
            adaptiveCard {
                VStack(spacing: 0) {
                    let transactions = datewiseTransactions[date] ?? []
                    
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        transactionRow(for: transaction)
                        
                        if index < transactions.count - 1 {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
            }
        }
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
                
                HStack(spacing: 6) {
                    Text(transaction.accountName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(transaction.date, style: .time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
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
}

private extension CashflowTransactionsView {
    var allTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
    }
    
    var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        return allTransactions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }
    
    var metricTransactions: [Transaction] {
        let cashflowTransactions = currentMonthTransactions.filter { $0.transactionType != .transfer }
        
        switch metric {
        case .expense:
            return cashflowTransactions.filter { $0.transactionType == .expense }
        case .income:
            return cashflowTransactions.filter { $0.transactionType == .income }
        }
    }
    
    var filteredTransactions: [Transaction] {
        metricTransactions.filter { transaction in
            guard !searchString.isEmpty else {
                return true
            }
            
            return transactionTitle(for: transaction).localizedStandardContains(searchString) ||
                transaction.accountName.localizedStandardContains(searchString) ||
                transaction.note.localizedStandardContains(searchString) ||
                String(transaction.amount).localizedStandardContains(searchString) ||
                transaction.date.description.localizedStandardContains(searchString)
        }
    }
    
    var datewiseTransactions: [Date: [Transaction]] {
        filteredTransactions.reduce(into: [Date: [Transaction]]()) { result, transaction in
            let date = transaction.date.resetTimeComponents
            result[date, default: []].append(transaction)
        }
    }
    
    var sortedTransactionDates: [Date] {
        datewiseTransactions.keys.sorted { $0 > $1 }
    }
    
    var metricAmount: Double {
        switch metric {
        case .expense:
            return abs(metricTransactions.reduce(0) { $0 + $1.amount })
        case .income:
            return metricTransactions.reduce(0) { $0 + $1.amount }
        }
    }
    
    var navigationTitle: String {
        switch metric {
        case .expense: return "Expenses"
        case .income: return "Income"
        }
    }
    
    var monthRangeDescription: String {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? Date()
        return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
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
    
    var positiveColor: Color {
        Color(hex: "#1F8F63")
    }
    
    var negativeColor: Color {
        Color(hex: "#E0554D")
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
        case .expense:
            return transaction.transactionCategory?.color ?? CashflowMetric.expense.tint
        case .income:
            return transaction.transactionCategory?.color ?? CashflowMetric.income.tint
        case .transfer:
            return Color(hex: "#8A63FF")
        }
    }
}
