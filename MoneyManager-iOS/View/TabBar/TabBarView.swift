//
//  TabBarView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 1/10/24.
//

import SwiftUI

struct TabBarView: View {
    private typealias Tab = TabBarModel.Item
    
    @State private var selectedTab: Tab = .home
    @State private var insightsPath = NavigationPath()
    private let tabBarTint = Color(hex: "#1F8F63")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView {
                selectedTab = .insights
                insightsPath = NavigationPath()
                insightsPath.append(InsightsView.Destination.detailMoneyFlow)
            }
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            NavigationStack {
                AllTransactionView()
            }
            .tabItem {
                Label(Tab.transactions.title, systemImage: Tab.transactions.icon)
            }
            .tag(Tab.transactions)
            
            NavigationStack(path: $insightsPath) {
                InsightsView()
            }
            .tabItem {
                Label(Tab.insights.title, systemImage: Tab.insights.icon)
            }
            .tag(Tab.insights)
            
            SettingsTabView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(tabBarTint)
    }
}
