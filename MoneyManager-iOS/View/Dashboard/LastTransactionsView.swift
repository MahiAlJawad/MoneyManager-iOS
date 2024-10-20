//
//  LastTransactionsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/10/24.
//

import SwiftUI
import SwiftData

struct LastTransactionsView: View {
    private typealias Destination = TransactionTabView.Router.Destination
    
    @Environment(DashboardTabView.Router.self) private var router
    @Query private var accounts: [Account]
    
    var transactions: [Transaction] {
        Array(
            accounts
                .flatMap(\.transactions)
                .sorted { $0.date > $1.date }
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
                router.navigate(to: .recordsView)
            } label: {
                Text("Show more")
            }
        }
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
                Text(transaction.date, format: .dateTime)
                    .font(.caption)
            }
        }
    }
}
