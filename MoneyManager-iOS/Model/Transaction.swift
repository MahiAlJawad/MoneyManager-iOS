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
    enum PaymentMethod: CaseIterable {
        case cash
        case creditCard
        case debitCard
        case banktransfer
        case voucher
        case mobilePayment
        case webPayment
        case other
        
        var description: String {
            switch self {
            case .cash:             return "Cash"
            case .creditCard:       return "Credit Card"
            case .debitCard:        return "Debit Card"
            case .banktransfer:     return "Bank Transfer"
            case .voucher:          return "Voucher"
            case .mobilePayment:    return "Mobile Payment"
            case .webPayment:       return "Web Payment"
            case .other:            return "Other"
            }
        }
    }
    
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
            default:       return .gray
            }
        }
    }
    
    var id: String
    private var type: String
    private(set) var amount: Double
    var category: String
    private(set) var date: Date
    private var paymentMethod: String
    
    // TODO: Add labels, notes when their corresponding model is created
    
    @Relationship(inverse: \Account.transactions)
    private var account: Account?
    
    init(
        type: TransactionType,
        account: Account,
        amount: Double,
        category: Category?,
        date: Date,
        labels: [String],
        paymentMethod: PaymentMethod
    ) {
        self.id = UUID().uuidString
        self.type = type.description
        self.account = account
        
        if type == .income {
            self.amount = amount
        } else {
            self.amount = amount * (-1)
        }
        
        self.category = category?.name ?? ""
        self.date = date
        self.paymentMethod = paymentMethod.description
    }
}

extension Transaction {
    var transactionCategory: Category? {
        let allCategories: [Category] = MainCategory.allCases + Subcategory.allCases
        
        return allCategories
            .first(where: { $0.name == category })
    }
    
    var accountName: String {
        account?.name ?? "Unknown"
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
            amount: amount,
            category: info.category,
            date: info.date,
            labels: [], // TODO: UI not ready
            paymentMethod: info.paymentMethod
        )
        
        // TODO: Handle Transfer type transaction not done yet as UI not ready
        account.addTransaction(transaction)
    }
}
