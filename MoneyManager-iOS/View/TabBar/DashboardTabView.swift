//
//  DashboardTabView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftUI

struct DashboardTabView: View {
    @State var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            DashboardView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .recordsView:
                        RecordsView()
                    }
                }
        }.environment(router)
    }
}

extension DashboardTabView {
    @Observable
    final class Router {
        public enum Destination: Hashable {
            case recordsView
            
            static func ==(lhs: Destination, rhs: Destination) -> Bool {
                switch (lhs, rhs) {
                case (.recordsView, .recordsView):
                    return true
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .recordsView:
                    hasher.combine("recordsView")
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
