//
//  Transaction.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 9/10/24.
//

import Foundation
import SwiftData

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
    }
    
    var id: String
    private var type: String
    private var ammount: Double
    private var category: String
    private var date: Date
    private var paymentMethod: String
    
    // TODO: Add labels, notes when their corresponding model is created
    
    @Relationship(inverse: \Account.transactions)
    private var account: Account?
    
    init(
        type: TransactionType,
        account: Account?,
        amount: String,
        category: Category?,
        date: Date,
        labels: [String],
        paymentMethod: PaymentMethod
    ) {
        self.id = UUID().uuidString
        self.type = type.description
        self.account = account
        
        if type == .income {
            self.ammount = Double(amount) ?? 0
        } else {
            self.ammount = (Double(amount) ?? 0) * (-1)
        }
        
        self.category = category?.name ?? ""
        self.date = date
        self.paymentMethod = paymentMethod.description
    }
}

extension Transaction {
    var transactionAmount: Double { ammount }
    
    static func addTransaction(from info: AddTransactionView.AddTransactionInfo) {
        guard let account = info.account else {
            print("Error: account not found")
            return
        }
        
        let transaction = Transaction(
            type: info.transactionType,
            account: info.account,
            amount: info.amount,
            category: info.category,
            date: info.date,
            labels: [], // TODO: UI not ready
            paymentMethod: info.paymentMethod
        )
        
        // TODO: Handle Transfer type transaction not done yet as UI not ready
        account.addTransaction(transaction)
    }
}
