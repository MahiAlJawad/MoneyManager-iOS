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
}

// MARK: Handles Account related DB manipulations
extension Account {
    enum AddAccountError: Error {
        case invalidBalance
        case invalidName
        case invalidCreditLimit
    }
    
    func addTransaction(_ transaction: Transaction) {
        balance += transaction.amount
        transactions.append(transaction)
    }
    
    static func addAccount(in modelContext: ModelContext, with accountInfo: AddAccountView.AddAccountInfo) throws {
        guard !accountInfo.name.isEmpty else {
            throw AddAccountError.invalidName
        }
                
        switch accountInfo.type {
        case .debit:
            guard let balance = Double(accountInfo.balance) else {
                throw AddAccountError.invalidBalance
            }
            
            modelContext.insert(
                Account(
                    name: accountInfo.name,
                    balance: balance,
                    type: .debit
                )
            )
            
        case .credit:
            guard let creditLimit = Double(accountInfo.creditLimit) else {
                throw AddAccountError.invalidCreditLimit
            }
            
            guard let balance = Double(accountInfo.balanceOutstanding) else {
                throw AddAccountError.invalidBalance
            }
            
            modelContext.insert(
                Account(
                    name: accountInfo.name,
                    balance: balance * (-1),
                    creditLimit: creditLimit,
                    billingDay: accountInfo.billingDate,
                    dueDay: accountInfo.dueDate,
                    type: .credit
                )
            )
        }
    }
}
