//
//  TestDataManager.swift
//  MoneyManager-iOS
//
//  Temporary debug helpers for seeding and clearing local SwiftData content.
//

import Foundation
import SwiftData

final class TestDataManager {
    static let shared = TestDataManager()
    
    private init() {}
    
    func seedHomeUITestData(in modelContext: ModelContext, transactionCount: Int = 200) {
        let existingAccounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
        
        let accounts: [Account]
        if existingAccounts.isEmpty {
            let seededAccounts = [
                Account(name: "Main Account", balance: 250_000, type: .debit),
                Account(name: "Cash Wallet", balance: 40_000, type: .debit),
                Account(name: "Savings", balance: 120_000, type: .debit),
                Account(
                    name: "Credit Card",
                    balance: -15_000,
                    creditLimit: 100_000,
                    billingDay: 5,
                    dueDay: 20,
                    type: .credit
                )
            ]
            
            seededAccounts.forEach { modelContext.insert($0) }
            accounts = seededAccounts
        } else {
            accounts = existingAccounts
        }
        
        let categories: [Category] = Transaction.MainCategory.allCases + Transaction.Subcategory.allCases
        let calendar = Calendar.current
        let now = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        
        for index in 0..<transactionCount {
            let transactionType = randomTransactionType()
            let randomTimeInterval = TimeInterval.random(in: 0...(now.timeIntervalSince(oneYearAgo)))
            let date = oneYearAgo.addingTimeInterval(randomTimeInterval)
            let amount = randomAmount(for: transactionType)
            
            switch transactionType {
            case .expense, .income:
                guard let account = accounts.randomElement(),
                      let category = categories.randomElement() else {
                    continue
                }
                
                let transaction = Transaction(
                    type: transactionType,
                    account: account,
                    amount: amount,
                    category: category,
                    transferAccount: nil,
                    date: date,
                    note: "Seeded transaction \(index + 1)"
                )
                
                account.addTransaction(transaction)
                
            case .transfer:
                guard accounts.count >= 2,
                      let fromAccount = accounts.randomElement() else {
                    continue
                }
                
                let possibleTargets = accounts.filter { $0.id != fromAccount.id }
                guard let toAccount = possibleTargets.randomElement() else {
                    continue
                }
                
                let transaction = Transaction(
                    type: .transfer,
                    account: fromAccount,
                    amount: amount,
                    category: nil,
                    transferAccount: toAccount,
                    date: date,
                    note: "Seeded transfer \(index + 1)"
                )
                
                fromAccount.addTransaction(transaction)
                toAccount.addTransaction(transaction)
            }
        }
        
        save(modelContext, successMessage: "Seeded \(transactionCount) debug transactions.")
    }
    
    func clearAllData(in modelContext: ModelContext) {
        let accounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
        
        for account in accounts {
            modelContext.delete(account)
        }
        
        save(modelContext, successMessage: "Cleared all accounts and transactions.")
    }
    
    private func randomTransactionType() -> Transaction.TransactionType {
        let typeRoll = Int.random(in: 0..<100)
        
        switch typeRoll {
        case 0..<55:
            return .expense
        case 55..<85:
            return .income
        default:
            return .transfer
        }
    }
    
    private func randomAmount(for transactionType: Transaction.TransactionType) -> Double {
        switch transactionType {
        case .expense:
            return Double.random(in: 80...12_000)
        case .income:
            return Double.random(in: 500...45_000)
        case .transfer:
            return Double.random(in: 200...20_000)
        }
    }
    
    private func save(_ modelContext: ModelContext, successMessage: String) {
        do {
            try modelContext.save()
            print(successMessage)
        } catch {
            print("Debug test data operation failed: \(error)")
        }
    }
}
