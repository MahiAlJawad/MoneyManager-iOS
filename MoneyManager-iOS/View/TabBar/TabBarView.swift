//
//  TabBarView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 1/10/24.
//

import SwiftUI

struct TabBarView: View {
    typealias Tab = TabBarModel.Item
    @State var selectedTab: Tab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Coming Soon")
                .tabItem {
                    Label(Tab.dashboard.title, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)
            
            NavigationStack {
                AccountsView()
            }
            .tabItem {
                Label(Tab.accounts.title, systemImage: Tab.accounts.icon)
            }
            .tag(Tab.accounts)
            
            Text("Coming Soon")
                .tabItem {
                    Label(Tab.statistics.title, systemImage: Tab.statistics.icon)
                }
                .tag(Tab.statistics)
            
            Text("Coming Soon")
                .tabItem {
                    Label(Tab.planning.title, systemImage: Tab.planning.icon)
                }
                .tag(Tab.planning)
            
            Text("Coming Soon")
                .tabItem {
                    Label(Tab.more.title, systemImage: Tab.more.icon)
                }
                .tag(Tab.more)
        }
    }
}
