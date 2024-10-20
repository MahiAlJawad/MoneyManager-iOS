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
    @State private var searchString: String = ""
    
    var transactions: [Transaction] {
        accounts
            .flatMap(\.transactions)
            .filter({ transaction in
                guard !searchString.isEmpty else {
                    return true
                }
                
                let categoryName = transaction.category
                let accountName = transaction.accountName
                let amount = String(transaction.amount)
                let date = transaction.date.description
                
                return categoryName.localizedStandardContains(searchString) ||
                accountName.localizedStandardContains(searchString) ||
                amount.localizedStandardContains(searchString) ||
                date.localizedStandardContains(searchString)
            })
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
        .searchable(text: $searchString)
        .navigationTitle("Transactions")
    }
    
    func transactionView(of transaction: Transaction) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text(transaction.category)
                        .font(.headline)
                    Text(transaction.accountName)
                        .font(.caption)
                }
            } icon: {
                Image(systemName: transaction.transactionCategory?.icon ?? "")
                    .foregroundStyle(transaction.transactionCategory?.color ?? .secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(transaction.amount, format: .currency(code: "BDT"))
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.transactionType.color)
                Text(transaction.date, style: .time)
                    .font(.caption)
            }
        }
    }
}
