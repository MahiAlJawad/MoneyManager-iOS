//
//  DashboardView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var accounts: [Account]
    
    private var showLastTransactionSection: Bool {
        accounts.map(\.transactions).count >= 1
    }
    
    var body: some View {
        if !showLastTransactionSection {
            VStack {
                Spacer()
                Text("Make some transactions first to see dashboard items.")
                Spacer()
            }
        }
        List {
            if showLastTransactionSection {
                Section("Last Transactions") {
                    LastTransactionsView()
                }
            }
        }
        .navigationTitle("Dashboard")
    }
}
