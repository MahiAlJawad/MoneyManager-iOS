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
            Section("Debit Accounts") {
                ForEach(debitAccounts) { account in
                    accountView(for: account)
                }
            }
            Section("Credit Accounts") {
                ForEach(creditAccounts) { account in
                    accountView(for: account)
                }
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // TODO: Add operation will be handled in a seperate view
                Button("Add", systemImage: "plus.circle.fill") {
                    let account = Account(name: "Demo Account \(Int.random(in: 1...100))", balance: Double.random(in: 1...1000), type: Bool.random() ? .debit : .credit)
                    
                    modelContext.insert(account)
                }
            }
        }
    }
    
    var debitAccounts: [Account] {
        accounts.filter({ $0.accountType == Account.AccountType.debit.description })
    }
    
    var creditAccounts: [Account] {
        accounts.filter({ $0.accountType == Account.AccountType.credit.description })
    }
    
    func accountView(for account: Account) -> some View {
        VStack(alignment: .leading) {
            Text(account.accountName)
                .font(.headline)
            Text(account.accountBalance, format: .currency(code: "BDT"))
            Text(account.accountType)
                .font(.caption)
        }
    }
}
