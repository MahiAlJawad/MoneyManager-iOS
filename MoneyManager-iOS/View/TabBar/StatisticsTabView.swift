//
//  StatisticsTabView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 20/10/24.
//

import SwiftUI

struct StatisticsTabView: View {
    @State var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            StatisticsView()
                .navigationDestination(for: Router.Destination.self) { destination in
                switch destination {
                case .spendingView:
                    ExpensesCardView()
                }
            }
        }
    }
}

extension StatisticsTabView {
    @Observable
    final class Router {
        public enum Destination: Hashable {
            case spendingView
            
            static func == (lhs: Destination, rhs: Destination) -> Bool {
                switch (lhs, rhs) {
                case (.spendingView, .spendingView):
                    return true
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .spendingView:
                    hasher.combine("spendingView")
                }
            }
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
