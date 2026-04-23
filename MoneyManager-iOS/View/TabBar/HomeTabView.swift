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
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .allTransactionsView:
                        AllTransactionView()
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
            TransactionTabView()
                .presentationDetents([.large])
        }
    }
    
    private var addTransactionButton: some View {
        Button {
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
