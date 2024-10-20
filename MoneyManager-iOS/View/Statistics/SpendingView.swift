//
//  Spending.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 20/10/24.
//

import SwiftUI
import SwiftData
import Charts

struct PieChartData: Identifiable {
    var id: String
    var category: String
    var amount: Double
}

struct ExpensesCardView: View {
    @State private var selectedTab = 0 // 0 for Categories, 1 for Labels
    
    @State private var selectedAngle: Double?
    
    @Query private var accounts: [Account]
    
    var transactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .filter { $0.transactionType == .expense }
    }
    
    var categoryWiseTransactions: [String: [Transaction]] {
        transactions.reduce(into: [String: [Transaction]]()) { partialResult, transaction in
            let key = transaction.category
            if partialResult[key] == nil { partialResult[key] = [] }
            partialResult[key]?.append(transaction)
        }
    }
    
    var pieChartData: [PieChartData] {
        var bags: [PieChartData] = []
        categoryWiseTransactions.forEach { item in
            print(item.key)
            let totalAmount = item.value.map(\.amount).reduce(0, +)
            let newElemnt = PieChartData(id: UUID().uuidString, category: item.key, amount: totalAmount)
            bags.append(newElemnt)
        }
        return bags.sorted { $0.amount > $1.amount }
    }
    
    private var categoryRanges: [(category: String, range: Range<Double>)] {
        var total = 0
        
        let ret = pieChartData.map {
            let newTotal = total - Int($0.amount)
            let result = (category: $0.category,
                          range: Double(total) ..< Double(newTotal))
            total = newTotal
            return result
        }
        print(ret)
        return ret
    }
    
    private var totalPosts: Int {
        var total = 0
        _ = pieChartData.map {
            let newTotal = total - Int($0.amount)
            total = newTotal
        }
        return total
    }
    
    private var data: [Transaction] { transactions }

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Expenses")
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
                Spacer()
            }
            
            Text("THIS MONTH")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding([.top, .leading])
            
            // Pie Chart
            chartView
            
            HStack {
                Spacer()
                Button("Show more") {
                    // Show more action
                }
                .foregroundColor(.blue)
                .padding([.trailing, .bottom])
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
    
    func totalAmount(in key: Transaction) -> Double {
        var total = 0.0
        data.forEach { transaction in
            if transaction.category == key.category {
                let newTotal = total + Double(transaction.amount)
                total = newTotal
            }
        }
        return total
    }
    
    var chartView: some View {
        Chart(pieChartData) { item in
            SectorMark(
                angle: .value("Count", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Category", item.category))
            .opacity(item.category == selectedItem?.category ? 1 : 0.5)
        }
        .scaledToFit()
        .chartLegend(alignment: .center, spacing: 16)
        .chartAngleSelection(value: $selectedAngle)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                if let anchor = chartProxy.plotFrame {
                    let frame = geometry[anchor]
                    titleView
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .padding()
    }
    
    private var titleView: some View {
        VStack {
            Text(selectedItem?.category ?? "All")
                .font(.title)
            
            var amount: Double {
                guard let selectedItem else { return Double(totalPosts) }
                let value = -selectedItem.amount
                return value
            }
                
            Text(amount.formatted() + " Taka")
                .font(.callout)
        }
    }
    
    var selectedItem: PieChartData? {
        guard let selectedAngle else { return nil }
        if let selected = categoryRanges.firstIndex(where: { $0.range.contains(-selectedAngle) }) {
            return pieChartData[selected]
        }
        return nil
    }
}
