//
//  AllTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 15/10/24.
//

import SwiftData
import SwiftUI

struct AllTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Transaction.date, order: .reverse)])
    private var allTransactions: [Transaction]
    @State private var searchString: String = ""
    @State private var transactionPendingDeletion: Transaction?
    @State private var transactionPendingEdit: Transaction?
    
    var transactions: [Transaction] {
        allTransactions.filter { transaction in
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
        }
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
        .alert("Delete transaction?", isPresented: deleteAlertBinding, presenting: transactionPendingDeletion) { transaction in
            Button("Delete", role: .destructive) {
                deleteTransaction(transaction)
            }
            Button("Cancel", role: .cancel) {
                transactionPendingDeletion = nil
            }
        } message: { transaction in
            Text("This will remove \(transactionTitle(for: transaction)) and update the account balance.")
        }
        .sheet(item: $transactionPendingEdit) { transaction in
            TransactionTabView(editingTransaction: transaction)
                .presentationDetents([.large])
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
                        if !transaction.note.isEmpty {
                            Text(transaction.note)
                                .font(.caption)
                        }
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
                        
                        if !transaction.note.isEmpty {
                            Text(transaction.note)
                                .font(.caption)
                        }
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
                Text(transaction.date, style: .time)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                transactionPendingEdit = transaction
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                transactionPendingDeletion = transaction
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { transactionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    transactionPendingDeletion = nil
                }
            }
        )
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        transaction.delete(in: modelContext)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete transaction: \(error)")
        }
        transactionPendingDeletion = nil
    }
    
    private func transactionTitle(for transaction: Transaction) -> String {
        if transaction.transactionType == .transfer {
            return "Transfer"
        }
        
        return transaction.category.isEmpty ? transaction.transactionType.description : transaction.category
    }
}
