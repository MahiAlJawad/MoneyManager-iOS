//
//  AccountsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 5/10/24.
//

import SwiftData
import SwiftUI

struct AccountsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var accounts: [Account]
    
    var body: some View {
        List {
            // TBD: Will be separated according to the types
            ForEach(accounts) { account in
                VStack(alignment: .leading) {
                    Text(account.accountName)
                        .font(.headline)
                    Text(account.accountBalance, format: .currency(code: "BDT"))
                    Text(account.accountType)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // TBD
                Button("Add", systemImage: "plus.circle.fill") {
                    let account = Account(name: "Demo Account \(Int.random(in: 1...100))", balance: Double.random(in: 1...1000), type: Bool.random() ? .debit : .credit)
                    
                    modelContext.insert(account)
                }
            }
        }
    }
}
