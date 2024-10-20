
import SwiftUI
import SwiftData

struct StatisticsView: View {
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(StatisticsMenuItem.statisticsMenuItem) { item in
                    switch item.title {
                    case "Spending":
                        NavigationLink(value: StatisticsTabView.Router.Destination.spendingView) {
                            StatisticsCellView(item: item)
                        }
                    
                    default:
                        NavigationLink(value: MoreTabBarView.Router.Destination.aboutWalletView) {
                            StatisticsCellView(item: item)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Statistics")
    }
}

struct StatisticsCellView: View {
    let item: StatisticsMenuItem
    
    var body: some View {
        VStack {
            Image(systemName: item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(20)
            
            Text(item.title)
                .font(.caption)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(minWidth: 150, maxHeight: 150, alignment: .center)
    }
}
