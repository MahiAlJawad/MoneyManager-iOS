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
        VStack(alignment: .leading) {
            HStack {
                Text("Expenses")
                    .font(.headline)
                    .padding(.leading)
                    .padding(.top)
                Spacer()
            }
            
            // TODO: need to change according to range selection
            Text("THIS MONTH")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding([.top, .leading])
            
            // Pie Chart
            pieChartView
            
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
    
    var pieChartView: some View {
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
                .font(.body)
            
            var amount: Double {
                guard let selectedItem else { return totalAmount }
                let value = -selectedItem.amount
                return value
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
    
    var pieChartData: [PieChartData] {
        var bags: [PieChartData] = []
        categoryWiseTransactions.forEach { item in
            let amount = item.value.map(\.amount).reduce(0, +)
            let newElemnt = PieChartData(id: UUID().uuidString, category: item.key, amount: amount)
            bags.append(newElemnt)
        }
        return bags.sorted { $0.amount > $1.amount }
    }
    
    var categoryRanges: [(category: String, range: Range<Double>)] {
        var total = 0
        let ranges = pieChartData.map {
            let newTotal = total - Int($0.amount)
            let result = (category: $0.category,
                          range: Double(total) ..< Double(newTotal))
            total = newTotal
            return result
        }
        return ranges
    }
    
    var totalAmount: Double {
        // TODO: need to change `-` sign when this code is used for income segment
        pieChartData.map(\.amount).reduce(0, -)
    }
    
    var selectedItem: PieChartData? {
        guard let selectedAngle else { return nil }
        if let selected = categoryRanges.firstIndex(where: { $0.range.contains(-selectedAngle) }) {
            return pieChartData[selected]
        }
        return nil
    }
}
    
