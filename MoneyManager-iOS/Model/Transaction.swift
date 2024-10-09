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
    
    // TODO: Add labels, notes when their corresponding model is created
    
    init(
        type: TransactionType,
        amount: String,
        category: Category,
        date: Date,
        labels: [String]
    ) {
        self.id = UUID().uuidString
        self.type = type.description
        self.ammount = Double(amount) ?? 0
        self.category = category.name
        self.date = date
    }
}
