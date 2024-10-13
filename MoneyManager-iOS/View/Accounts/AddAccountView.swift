//
//  AddAccountView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) var dissmiss
    @Environment(\.modelContext) var modelContext
    @State var accountInfo: AddAccountInfo = .init()
        
    var body: some View {
        Form {
            Section("Account Name") {
                TextField("e.g. Cash Account", text: $accountInfo.name)
            }
            Section("Account Type") {
                Picker("Account Type", selection: $accountInfo.type) {
                    ForEach(Account.AccountType.allCases, id: \.description) { type in
                        Text(type.description)
                            .tag(type)
                    }
                }
            }
            
            if accountInfo.type == .debit {
                Section("Balance") {
                    TextField("e.g. $1000", text: $accountInfo.balance)
                        .keyboardType(.numberPad)
                }
            } else {
                Section("Credit Limit") {
                    TextField("e.g. $150000", text: $accountInfo.creditLimit)
                        .keyboardType(.numberPad)
                }
                Section("Balance Outstanding / Owed") {
                    TextField("e.g. $1000", text: $accountInfo.balanceOutstanding)
                        .keyboardType(.numberPad)
                }
                Picker("Billing date of the month", selection: $accountInfo.billingDate) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                    }
                }
                Picker("Due date of the month", selection: $accountInfo.dueDate) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                    }
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dissmiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    addAccount()
                    dissmiss()
                }
                .disabled(!isEnabledSaveButton)
            }
        })
        .navigationTitle("Add Account")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isEnabledSaveButton: Bool {
        if accountInfo.type == .debit {
            return !accountInfo.name.isEmpty && !accountInfo.balance.isEmpty
        } else {
            return !accountInfo.name.isEmpty &&
            !accountInfo.creditLimit.isEmpty &&
            !accountInfo.balanceOutstanding.isEmpty
        }
    }
    
    private func addAccount() {
        Account.addAccount(in: modelContext, with: accountInfo)
    }
}

extension AddAccountView {
    struct AddAccountInfo {
        var name: String = ""
        var type: Account.AccountType = .debit
        var balance: String = ""
        
        // For Credit type accounts
        var creditLimit: String = ""
        var balanceOutstanding: String = ""
        var billingDate: Int = 1
        var dueDate: Int = 15
    }
}

#Preview {
    NavigationStack {
        AddAccountView()
    }
}
