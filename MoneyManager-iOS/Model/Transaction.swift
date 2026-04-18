//
//  Transaction.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 9/10/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Transaction {
    enum TransactionType {
        case expense
        case income
        case transfer
        
        var description: String {
            switch self {
            case .expense:          return "Expense"
            case .income:           return "Income"
            case .transfer:         return "Transfer"
            }
        }
        
        var color: Color {
            switch self {
            case .expense: return .red
            case .income:  return .green
            case .transfer: return .blue
            }
        }
    }
    
    var id: String
    private var type: String
    private(set) var amount: Double
    private(set) var category: String
    private(set) var date: Date
    private(set) var note: String
    private(set) var account: Account
    private(set) var transferAccount: Account?
    
    @Relationship(inverse: \Account.transactions)
    private var accounts: [Account]
    
    init(
        type: TransactionType,
        account: Account,
        amount: Double,
        category: Category?,
        transferAccount: Account?,
        date: Date,
        note: String
    ) {
        self.id = UUID().uuidString
        self.type = type.description
        self.accounts = [account]
        
        self.account = account
        if let transferAccount {
            self.accounts = [account, transferAccount]
            self.transferAccount = transferAccount
        } else {
            self.accounts = [account]
        }
        
        if type == .expense {
            self.amount = amount * (-1)
        } else {
            self.amount = amount
        }
        
        self.category = category?.name ?? ""
        self.date = date
        self.note = note
    }
}

extension Transaction {
    var transactionCategory: Category? {
        let allCategories: [Category] = MainCategory.allCases + Subcategory.allCases
        
        return allCategories
            .first(where: { $0.name == category })
    }
    
    var accountName: String {
        account.name
    }
    
    var transferAccountName: String {
        transferAccount?.name ?? "Unknown"
    }
    
    var transactionType: TransactionType {
        switch type {
        case TransactionType.income.description:
            return .income
        case TransactionType.expense.description:
            return .expense
        default:
            return .transfer
        }
    }
    
    static var allMainCategories: [MainCategory] {
        [.Groceries, .Communication, .Housing, .Life_Entertainment,
         .Shopping , .Transportation ,.Restaurant]
    }
}

// MARK: Handles Add Transaction
extension Transaction {
    enum AddTransactionError: Error {
        case accountNotFound
        case invalidAmount
    }
    
    static func addTransaction(from info: AddTransactionView.AddTransactionInfo) throws {
        guard let account = info.account else {
            throw AddTransactionError.accountNotFound
        }
        
        guard let amount = Double(info.amount) else {
            throw AddTransactionError.invalidAmount
        }
        
        let transaction = Transaction(
            type: info.transactionType,
            account: account,
            amount: amount*(info.currency.conversionRate ?? 1.0),
            category: info.category,
            transferAccount: info.transferAccount,
            date: info.date,
            note: info.note
        )
        
        account.addTransaction(transaction)
        info.transferAccount?.addTransaction(transaction)
    }
}
