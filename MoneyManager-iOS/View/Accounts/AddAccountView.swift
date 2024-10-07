//
//  AddAccountView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) var dissmiss
    
    @State private var accountName: String = ""
    @State private var accountType: Account.AccountType = .debit
    @State private var balance: String = ""
    
    // For Credit type accounts
    @State private var creditLimit: String = ""
    @State private var balanceOutstanding: String = ""
    @State private var billingDate: Int = 1
    @State private var dueDate: Int = 15
    
    var body: some View {
        Form {
            Section("Account Name") {
                TextField("e.g. Cash Account", text: $accountName)
            }
            Section("Account Type") {
                Picker("Account Type", selection: $accountType) {
                    ForEach(Account.AccountType.allCases, id: \.description) { type in
                        Text(type.description)
                            .tag(type)
                    }
                }
            }
            
            if accountType == .debit {
                Section("Balance") {
                    TextField("e.g. $1000", text: $balance)
                        .keyboardType(.numberPad)
                }
            } else {
                Section("Credit Limit") {
                    TextField("e.g. $150000", text: $creditLimit)
                        .keyboardType(.numberPad)
                }
                Section("Balance Outstanding / Owed") {
                    TextField("e.g. $1000", text: $balanceOutstanding)
                        .keyboardType(.numberPad)
                }
                Picker("Billing date of the month", selection: $billingDate) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                    }
                }
                Picker("Due date of the month", selection: $dueDate) {
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
                    // Add Account Action
                    dissmiss()
                }
            }
        })
        .navigationTitle("Add Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AddAccountView()
    }
}
