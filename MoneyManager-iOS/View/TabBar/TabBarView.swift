//
//  TabBarView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 1/10/24.
//

import SwiftUI

struct TabBarView: View {
    private typealias Tab = TabBarModel.Item
    @State private var selectedTab: Tab = .dashboard
    @State private var presentAddTransactionSheet: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Text("Dashbaord")
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
                
                Spacer()
                    .tabItem {
                        EmptyView()
                    }
                    .tag(0)
                
                Text("Statistics")
                    .tabItem {
                        Label(Tab.statistics.title, systemImage: Tab.statistics.icon)
                    }
                    .tag(Tab.statistics)
                
                Text("More View")
                    .tabItem {
                        Label(Tab.more.title, systemImage: Tab.more.icon)
                    }
                    .tag(Tab.more)
            }

            // MARK: Add Transaction button
            Button {
                presentAddTransactionSheet.toggle()
            } label: {
                Image(systemName: "plus")
                    .tint(Color.white)
                    .padding()
            }
            .background(Color.green)
            .clipShape(Circle())
        }
        .sheet(isPresented: $presentAddTransactionSheet) {
            NavigationStack {
                AddTransactionView()
            }
            .presentationDetents([.medium, .large])
        }
    }
}
