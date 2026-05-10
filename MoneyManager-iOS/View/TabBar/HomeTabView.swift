//
//  HomeTabView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftUI

struct HomeTabView: View {
    @State var router = Router()
    @State private var presentAddTransactionSheet = false
    @State private var addTransactionType: Transaction.TransactionType = .expense
    let openDetailMoneyFlowInInsights: () -> Void
    
    init(openDetailMoneyFlowInInsights: @escaping () -> Void = {}) {
        self.openDetailMoneyFlowInInsights = openDetailMoneyFlowInInsights
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView { transactionType in
                addTransactionType = transactionType
                presentAddTransactionSheet = true
            }
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .allTransactionsView:
                        AllTransactionView()
                    case .accountsView:
                        AccountsView()
                    case .balanceDetailsView:
                        BalanceDetailsView()
                    case .balanceTrendDetailsView:
                        BalanceTrendDetailsView()
                    case .monthlyMoneyFlowView(let metric):
                        MonthlyMoneyFlowView(
                            initialMetric: metric,
                            openDetailMoneyFlow: openDetailMoneyFlowInInsights
                        )
                    case .cashflowTransactionsView(let metric):
                        CashflowTransactionsView(metric: metric)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        addTransactionButton
                    }
                }
        }
        .environment(router)
        .sheet(isPresented: $presentAddTransactionSheet) {
            TransactionTabView(initialTransactionType: addTransactionType)
                .presentationDetents([.large])
        }
    }
    
    private var addTransactionButton: some View {
        Button {
            addTransactionType = .expense
            presentAddTransactionSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .accessibilityLabel("Add transaction")
    }
}

extension HomeTabView {
    @Observable
    final class Router {
        enum Destination: Hashable {
            case allTransactionsView
            case accountsView
            case balanceDetailsView
            case balanceTrendDetailsView
            case monthlyMoneyFlowView(CashflowMetric)
            case cashflowTransactionsView(CashflowMetric)
        }
        
        var path = NavigationPath()
        
        func navigate(to destination: Destination) {
            path.append(destination)
        }
        
        func navigateBack() {
            path.removeLast()
        }
        
        func navigateToRoot() {
            path.removeLast()
        }
    }
}

private struct BalanceTrendDetailsView: View {
    var body: some View {
        Text("Balance Trend")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .navigationTitle("Balance Trend")
            .navigationBarTitleDisplayMode(.inline)
    }
}
