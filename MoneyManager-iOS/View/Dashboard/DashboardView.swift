//
//  DashboardView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        List {
            Section("Last Transactions") {
                LastTransactionsView()
            }
        }
        .navigationTitle("Dashboard")
    }
}
