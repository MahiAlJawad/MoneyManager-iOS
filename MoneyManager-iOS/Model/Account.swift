//
//  Account.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 5/10/24.
//

import Foundation
import SwiftData

@Model
class Account {
    enum AccountType: CaseIterable {
        case debit
        case credit
        
        var description: String {
            switch self {
            case .debit: return "Debit"
            case .credit: return "Credit"
            }
        }
    }
    
    var id: String
    private var name: String
    private var balance: Double
    private var type: String
    
    // For Credit type account
    private var creditLimit: Double
    private var billingDay: Int
    private var dueDay: Int
    
    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction]
    
    init(
        name: String,
        balance: Double,
        creditLimit: Double = 0,
        billingDay: Int = 0,
        dueDay: Int = 0,
        type: AccountType
    ) {
        id = UUID().uuidString
        self.name = name
        self.balance = balance
        self.type = type.description
        self.creditLimit = creditLimit
        self.billingDay = billingDay
        self.dueDay = dueDay
        self.transactions = []
    }
}

extension Account {
    var accountName: String { name }
    
    var accountBalance: Double { balance }
    
    var accountType: AccountType {
        type == AccountType.credit.description ? .credit : .debit
    }
    
    var iconName: String {
        accountType == .debit ? "dollarsign.bank.building.fill" : "creditcard.fill"
    }
    
    func addTransaction(_ transaction: Transaction) {
        balance += transaction.transactionAmount
        transactions.append(transaction)
    }
    
    static func addAccount(in modelContext: ModelContext, with accountInfo: AddAccountView.AddAccountInfo) {
        let account: Account = {
            switch accountInfo.type {
            case .debit:
                return Account(
                    name: accountInfo.name,
                    balance: Double(accountInfo.balance) ?? 0,
                    type: .debit
                )
                
            case .credit:
                let balance = (Double(accountInfo.balanceOutstanding) ?? 0) * (-1)
                
                return Account(
                    name: accountInfo.name,
                    balance: balance,
                    creditLimit: Double(accountInfo.creditLimit) ?? 0,
                    billingDay: Int(accountInfo.billingDate),
                    dueDay: Int(accountInfo.dueDate),
                    type: .credit
                )
            }
        }()
        
        modelContext.insert(account)
    }
}
