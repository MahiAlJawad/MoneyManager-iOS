//
//  AccountsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 5/10/24.
//

import SwiftData
import SwiftUI

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @State private var presentAddAccountView: Bool = false
    
    var body: some View {
        VStack {
            if accounts.isEmpty {
                Text("No accounts available yet. Please add an account to get started.")
                    .font(.title3)
            } else {
                accountsListView
            }
            Button("Add Account") {
                presentAddAccountView.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Accounts")
        .navigationTitle("Accounts")
        .sheet(isPresented: $presentAddAccountView) {
            NavigationView {
                AddAccountView()
            }
        }
    }
    
    private var accountsListView: some View {
        List {
            ForEach(accountTypes, id: \.description) { accountType in
                Section(accountType.description) {
                    switch accountType {
                    case .debit:
                        ForEach(debitAccounts) { account in
                            accountView(for: account)
                        }
                    case .credit:
                        ForEach(creditAccounts) { account in
                            accountView(for: account)
                        }
                    }
                }
            }
            .onDelete(perform: dummyDeleteAccount) // TODO: Dummy code, will be replaced
        }
    }
    
    private var accountTypes: [Account.AccountType] {
        Array(Set(accounts.map(\.accountType)))
    }
    
    private var debitAccounts: [Account] {
        accounts.filter({ $0.accountType == .debit })
    }
    
    private var creditAccounts: [Account] {
        accounts.filter({ $0.accountType == .credit })
    }
    
    private func accountView(for account: Account) -> some View {
        VStack(alignment: .leading) {
            Text(account.accountName)
                .font(.headline)
            Text(account.accountBalance, format: .currency(code: "BDT"))
            Text(account.accountType.description)
                .font(.caption)
        }
    }
    
    // Dummy code just to delete temporarily, will be replaced
    private func dummyDeleteAccount(at indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(accounts[index])
        }
    }
}
