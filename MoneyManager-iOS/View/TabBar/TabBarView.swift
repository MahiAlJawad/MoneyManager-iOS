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
    @State private var presentFinanceBot = false
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
            
            BudgetTabView()
                .tabItem {
                    Label(Tab.budget.title, systemImage: Tab.budget.icon)
                }
                .tag(Tab.budget)
            
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
        .overlay(alignment: .bottomTrailing) {
            financeBotButton
                .padding(.trailing, 28)
                .padding(.bottom, 76)
        }
        .sheet(isPresented: $presentFinanceBot) {
            NavigationStack {
                FinanceBotView()
            }
            .presentationDetents([.large])
        }
    }

    private var financeBotButton: some View {
        Button {
            presentFinanceBot = true
        } label: {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(tabBarTint.gradient, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: tabBarTint.opacity(0.35), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open FinanceBot")
    }
}
