//
//  MoneyFlowViewCard.swift
//  MoneyManager-iOS
//
//  Created by Codex on 30/4/26.
//

import Charts
import SwiftData
import SwiftUI

struct MoneyFlowViewCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    var body: some View {
        NavigationLink(value: InsightsView.Destination.detailMoneyFlow) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Money Flow")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                        
                        Text(monthRangeDescription)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(balanceColor)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(balanceColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                        )
                }
                
                if chartPoints.contains(where: { $0.income > 0 || $0.expense > 0 }) {
                    VStack(alignment: .leading, spacing: 10) {
                        chartPreviewTitle("Income & Expense")
                        
                        Chart {
                            ForEach(chartPoints) { point in
                                BarMark(
                                    x: .value("Day", point.day),
                                    y: .value("Income", point.income)
                                )
                                .foregroundStyle(incomeColor.opacity(0.82))
                                
                                BarMark(
                                    x: .value("Day", point.day),
                                    y: .value("Expense", -point.expense)
                                )
                                .foregroundStyle(expenseColor.opacity(0.82))
                            }
                        }
                        .frame(height: 62)
                        .chartLegend(.hidden)
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Add transactions to see monthly flow.")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 112)
                }
                
                HStack(spacing: 10) {
                    metricPill("Expense", monthlyExpense, expenseColor)
                    metricPill("Income", monthlyIncome, incomeColor)
                }
            }
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
        .buttonStyle(.plain)
        .accessibilityLabel("Open detailed money flow")
    }
    
    private func chartPreviewTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }
    
    private func metricPill(_ title: String, _ amount: Double, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(amount, format: .currency(code: "BDT"))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension MoneyFlowViewCard {
    struct MoneyFlowPoint: Identifiable {
        let day: Int
        let date: Date
        let income: Double
        let expense: Double
        
        var id: Date { date }
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
    
    var chartPoints: [MoneyFlowPoint] {
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let groupedTransactions = Dictionary(grouping: currentMonthTransactions) {
            calendar.component(.day, from: $0.date)
        }
        
        guard let days = calendar.range(of: .day, in: .month, for: Date()) else {
            return []
        }
        
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
            
            return MoneyFlowPoint(day: day, date: date, income: income, expense: expense)
        }
    }
    
    var monthRangeDescription: String {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? Date()
        return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
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
    
    var incomeColor: Color {
        Color(hex: "#1F8F63")
    }
    
    var expenseColor: Color {
        Color(hex: "#E0554D")
    }
    
    var balanceColor: Color {
        Color(hex: "#5B5CEB")
    }
    
}
