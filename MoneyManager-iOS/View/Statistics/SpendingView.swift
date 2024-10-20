import Charts
import SwiftData
import SwiftUI

struct PieChartData: Identifiable {
    var id: String
    var category: String
    var amount: Double
}

struct ExpensesCardView: View {
    @State private var selectedAngle: Double?
    @Query private var accounts: [Account]
    
    var body: some View {
        ScrollView {
            pieChartView
            barChartView
        }
        .navigationTitle("Expenses")
    }
    
    var pieChartView: some View {
        Chart(chartData, id: \.category) { item in
            SectorMark(
                angle: .value("Count", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Category", item.category))
            .opacity(item.category == selectedItem?.category ? 1 : 0.5)
        }
        .padding()
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
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
    
    var barChartView: some View {
        Chart(chartData) { item in
            BarMark(
                x: .value("Amount", item.amount),
                y: .value("Category", item.category + ": " + item.amount.formatted())
            )
            .cornerRadius(2)
            .foregroundStyle(by: .value("Category", item.category))
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .padding()
        .scaledToFit()
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
    
    private var titleView: some View {
        VStack {
            Text(selectedItem?.category ?? "All")
                .font(.body)
            
            var amount: Double {
                guard let selectedItem else { return totalAmount }
                return selectedItem.amount
            }
                
            Text(amount.formatted() + " Taka")
                .font(.callout)
        }
    }
}

private extension ExpensesCardView {
    var allExpenseTransactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .filter { $0.transactionType == .expense }
    }
    
    var categoryWiseTransactions: [String: [Transaction]] {
        allExpenseTransactions.reduce(into: [String: [Transaction]]()) { partialResult, transaction in
            let key = transaction.category
            if partialResult[key] == nil { partialResult[key] = [] }
            partialResult[key]?.append(transaction)
        }
    }
    
    var chartData: [PieChartData] {
        var bags: [PieChartData] = []
        categoryWiseTransactions.forEach { item in
            let amount = item.value.map(\.amount).reduce(0, +)
            let newElemnt = PieChartData(id: UUID().uuidString, category: item.key, amount: -amount)
            bags.append(newElemnt)
        }
        return bags.sorted { $0.amount > $1.amount }
    }
    
    var categoryRanges: [(category: String, range: Range<Double>)] {
        var total = 0
        let ranges = chartData.map {
            let newTotal = total + Int($0.amount)
            let result = (category: $0.category,
                          range: Double(total) ..< Double(newTotal))
            total = newTotal
            return result
        }
        return ranges
    }
    
    var totalAmount: Double {
        chartData.map(\.amount).reduce(0, +)
    }
    
    var selectedItem: PieChartData? {
        guard let selectedAngle else { return nil }
        if let selected = categoryRanges.firstIndex(where: { $0.range.contains(selectedAngle) }) {
            return chartData[selected]
        }
        return nil
    }
}
    
