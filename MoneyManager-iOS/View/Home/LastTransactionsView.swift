//
//  LastTransactionsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftData
import SwiftUI

struct LastTransactionsView: View {
    private typealias Destination = TransactionTabView.Router.Destination
    
    @Environment(HomeTabView.Router.self) private var router
    @Query private var accounts: [Account]
    
    private var transactions: [Transaction] {
        Array(
            accounts
                .flatMap(\.transactions)
                .sorted { $0.date > $1.date }
                .removeConsecutiveDuplicates()
                .prefix(3)
        )
    }
    
    var body: some View {
        ForEach(transactions) { transaction in
            transactionView(of: transaction)
        }
        HStack {
            Spacer()
            Button {
                router.navigate(to: .allTransactionsView)
            } label: {
                Text("Show more")
            }
        }
    }
    
    func transactionView(of transaction: Transaction) -> some View {
        HStack {
            if transaction.transactionType == .transfer {
                Label {
                    VStack(alignment: .leading) {
                        Text(transaction.transactionType.description)
                            .font(.headline)
                        Text("\(transaction.accountName) -> \(transaction.transferAccountName)")
                            .font(.caption)
                    }
                } icon: {
                    Image(systemName: "arrow.left.arrow.right.circle")
                        .foregroundStyle(transaction.transactionCategory?.color ?? .secondary)
                }
            } else {
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
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(transaction.amount, format: .currency(code: "BDT"))
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.transactionType.color)
                Text(transaction.date, format: .dateTime)
                    .font(.caption)
            }
        }
    }
}
