//
//  Transaction.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//

import SwiftData
import SwiftUI

@Model
class TransactionViewData {
    enum type {
        case general
        case detail
    }
    
    var id: String
    private var selectedTab = 0 // 0: Expense, 1: Income, 2: Transfer
    private var amount: Int = 0
    private var account: String? = "Cash"
    //private var category: Category?
    private var dateTime: Date = Date()
    
    init(
        id: String,
        selectedTab: Int = 0,
        amount: Int,
        account: String? = nil,
        //category: Category? = nil,
        dateTime: Date
    ) {
        self.id = UUID().uuidString
        self.selectedTab = selectedTab
        self.amount = amount
        self.account = account
        //self.category = category
        self.dateTime = dateTime
    }
}

extension TransactionViewData {
    var transactionAmount: Int { amount }
}
