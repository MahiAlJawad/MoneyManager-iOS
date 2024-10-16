//
//  RecordsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 15/10/24.
//

import SwiftData
import SwiftUI

struct RecordsView: View {
    @Query private var accounts: [Account]
    // TODO: Add search functionality
    
    var transactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .sorted { $0.date > $1.date }
    }
    
    var datewiseTransactions: [Date: [Transaction]] {
        transactions.reduce(into: [Date: [Transaction]]()) { partialResult, transaction in
            let dateWithoutTime = transaction.date.resetTimeComponents
            if partialResult[dateWithoutTime] == nil {
                partialResult[dateWithoutTime] = []
            }
            
            partialResult[dateWithoutTime]?.append(transaction)
        }
    }
    
    var body: some View {
        List {
            ForEach(Array(datewiseTransactions.keys).sorted(by: { $0 > $1 }), id: \.self) { section in
                Section {
                    ForEach(datewiseTransactions[section] ?? []) { transaction in
                        transactionView(of: transaction)
                    }
                } header: {
                    Text(section, style: .date)
                }
            }
        }
        .navigationTitle("Transactions")
    }
    
    func transactionView(of transaction: Transaction) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text(transaction.transactionCategory)
                        .font(.headline)
                    Text(transaction.accountName)
                        .font(.caption)
                }
            } icon: {
                Image(systemName: transaction.transactionType.iconName)
                    .foregroundStyle(transaction.transactionType.color)
            }
            Spacer()
            VStack(alignment: .trailing) {
                // TODO: Transaction should store currency name
                Text(transaction.amount, format: .currency(code: "BDT"))
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.transactionType.color)
                Text(transaction.date, style: .time)
                    .font(.caption)
            }
        }
    }
}
