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
    enum AccountType {        
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
    
    private var creditLimit: Double
    
    init(
        name: String,
        balance: Double,
        creditLimit: Double = 0,
        type: AccountType
    ) {
        id = UUID().uuidString
        self.name = name
        self.balance = balance
        self.type = type.description
        self.creditLimit = creditLimit
    }
}

extension Account {
    var accountName: String { name }
    
    var accountBalance: Double { balance }
    
    var accountType: AccountType {
        type == AccountType.credit.description ? .credit : .debit
    }
}
