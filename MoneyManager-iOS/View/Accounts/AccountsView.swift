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
                        .onDelete { deleteAccount(at: $0, type: .debit) }
                    case .credit:
                        ForEach(creditAccounts) { account in
                            accountView(for: account)
                        }
                        .onDelete { deleteAccount(at: $0, type: .credit) }
                    }
                }
            }
            
        }
    }
    
    private var accountTypes: [Account.AccountType] {
        let availableAccountTypes = accounts.map(\.accountType)
        
        return Account.AccountType.allCases.filter {
            availableAccountTypes.contains($0)
        }
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
    
    private func deleteAccount(at indexSet: IndexSet, type: Account.AccountType) {
        for index in indexSet {
            switch type {
            case .credit:
                modelContext.delete(creditAccounts[index])
            case .debit:
                modelContext.delete(debitAccounts[index])
            }
        }
    }
}
