//
//  AccountTransactionsView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 14/5/26.
//

import SwiftData
import SwiftUI

struct AccountTransactionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [.init(\Account.name)]) private var accounts: [Account]
    
    @State private var searchString = ""
    @State private var transactionPendingDeletion: Transaction?
    @State private var transactionPendingEdit: Transaction?
    @State private var rowOffsets: [String: CGFloat] = [:]
    
    let accountID: String
    
    var body: some View {
        Group {
            if let account {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerSection(for: account)
                        
                        if datewiseTransactions(for: account).isEmpty {
                            adaptiveCard {
                                emptyState(
                                    title: "No matching activity",
                                    subtitle: "Try changing your search or add more transactions for this account.",
                                    systemImage: "tray"
                                )
                            }
                        } else {
                            ForEach(Array(datewiseTransactions(for: account).keys).sorted(by: { $0 > $1 }), id: \.self) { date in
                                transactionDateSection(date, account: account)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .background(screenBackground.ignoresSafeArea())
                .searchable(text: $searchString)
                .navigationTitle("\(account.name) Activity")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(item: $transactionPendingEdit) { transaction in
                    TransactionTabView(editingTransaction: transaction)
                        .presentationDetents([.large])
                }
                .alert("Delete transaction?", isPresented: deleteAlertBinding, presenting: transactionPendingDeletion) { transaction in
                    Button("Delete", role: .destructive) {
                        deleteTransaction(transaction)
                    }
                    Button("Cancel", role: .cancel) {
                        transactionPendingDeletion = nil
                    }
                } message: { transaction in
                    Text("This will remove \(transactionTitle(for: transaction, in: account)) and update the account balance.")
                }
            } else {
                missingAccountView
            }
        }
    }
}

private extension AccountTransactionsView {
    var account: Account? {
        accounts.first { $0.id == accountID }
    }
    
    var primaryTextColor: Color {
        Color(uiColor: .label)
    }

    var screenBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }

    var cardBackground: Color {
        Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground)
    }

    var cardStrokeColor: Color {
        Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.04)
    }

    var shadowColor: Color {
        colorScheme == .dark ? .clear : .black.opacity(0.08)
    }
    
    var positiveColor: Color {
        Color(hex: "#1F8F63")
    }
    
    var negativeColor: Color {
        Color(hex: "#E0554D")
    }
    
    var transferColor: Color {
        Color(hex: "#5B5CEB")
    }
    
    var missingAccountView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text("Account not found")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(primaryTextColor)
            
            Text("This account may have been removed.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
    }

    func headerSection(for account: Account) -> some View {
        adaptiveCard {
            HStack(spacing: 12) {
                Circle()
                    .fill(accountTint(for: account).opacity(colorScheme == .dark ? 0.20 : 0.12))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: accountSymbol(for: account))
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(accountTint(for: account))
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(account.accountBalance, format: .currency(code: "BDT"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    Text("\(accountTransactions(for: account).count) transactions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
        }
    }

    func transactionDateSection(_ date: Date, account: Account) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(date, style: .date)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)
            
            adaptiveCard {
                VStack(spacing: 0) {
                    let transactions = datewiseTransactions(for: account)[date] ?? []
                    
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        swipeableTransactionRow(for: transaction, in: account)
                        
                        if index < transactions.count - 1 {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
            }
        }
    }
    
    func accountTransactions(for account: Account) -> [Transaction] {
        account.transactions
            .sorted { $0.date > $1.date }
            .removeConsecutiveDuplicates()
            .filter { transaction in
                guard !searchString.isEmpty else {
                    return true
                }
                
                return transactionTitle(for: transaction, in: account).localizedStandardContains(searchString) ||
                    transaction.accountName.localizedStandardContains(searchString) ||
                    transaction.transferAccountName.localizedStandardContains(searchString) ||
                    String(accountImpact(of: transaction, for: account)).localizedStandardContains(searchString) ||
                    transaction.date.description.localizedStandardContains(searchString)
            }
    }
    
    func datewiseTransactions(for account: Account) -> [Date: [Transaction]] {
        accountTransactions(for: account).reduce(into: [Date: [Transaction]]()) { partialResult, transaction in
            let dateWithoutTime = transaction.date.resetTimeComponents
            if partialResult[dateWithoutTime] == nil {
                partialResult[dateWithoutTime] = []
            }
            
            partialResult[dateWithoutTime]?.append(transaction)
        }
    }
    
    func transactionRow(for transaction: Transaction, in account: Account) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(transactionTint(for: transaction, in: account).opacity(colorScheme == .dark ? 0.20 : 0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: transactionIcon(for: transaction))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(transactionTint(for: transaction, in: account))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transactionTitle(for: transaction, in: account))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 6) {
                    Text(transactionPeerLabel(for: transaction, in: account))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(transaction.date, style: .time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            Text(accountImpact(of: transaction, for: account), format: .currency(code: "BDT"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(transactionTint(for: transaction, in: account))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
    }

    func swipeableTransactionRow(for transaction: Transaction, in account: Account) -> some View {
        let offset = rowOffsets[transaction.id] ?? 0
        
        return ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                transactionPendingDeletion = transaction
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 82)
                    .frame(maxHeight: .infinity)
                    .background(negativeColor)
            }
            .buttonStyle(.plain)
            .opacity(offset < -8 ? 1 : 0)
            
            transactionRow(for: transaction, in: account)
                .padding(.horizontal, 16)
                .background(cardBackground)
                .offset(x: offset)
                .contentShape(Rectangle())
                .onTapGesture {
                    if offset < -8 {
                        rowOffsets[transaction.id] = 0
                    } else {
                        transactionPendingEdit = transaction
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 18)
                        .onChanged { value in
                            let currentOffset = rowOffsets[transaction.id] ?? 0
                            let proposedOffset = value.translation.width < 0
                                ? value.translation.width
                                : currentOffset + value.translation.width
                            
                            rowOffsets[transaction.id] = min(0, max(-82, proposedOffset))
                        }
                        .onEnded { _ in
                            let finalOffset = rowOffsets[transaction.id] ?? 0
                            rowOffsets[transaction.id] = finalOffset < -40 ? -82 : 0
                        }
                )
                .animation(.snappy(duration: 0.2), value: offset)
        }
        .padding(.horizontal, -16)
        .clipped()
    }
    
    func transactionTitle(for transaction: Transaction, in account: Account) -> String {
        if transaction.transactionType == .transfer {
            if transaction.account == account {
                return "Transfer to \(transaction.transferAccountName)"
            }
            
            return "Transfer from \(transaction.accountName)"
        }
        
        return transaction.category.isEmpty ? transaction.transactionType.description : transaction.category
    }
    
    func transactionIcon(for transaction: Transaction) -> String {
        if transaction.transactionType == .transfer {
            return "arrow.left.arrow.right"
        }
        
        return transaction.transactionCategory?.icon ?? (transaction.transactionType == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
    }
    
    func transactionTint(for transaction: Transaction, in account: Account) -> Color {
        if transaction.transactionType == .transfer {
            return accountImpact(of: transaction, for: account) >= 0 ? positiveColor : transferColor
        }
        
        switch transaction.transactionType {
        case .income:
            return positiveColor
        case .expense:
            return transaction.transactionCategory?.color ?? negativeColor
        case .transfer:
            return transferColor
        }
    }
    
    func accountImpact(of transaction: Transaction, for account: Account) -> Double {
        guard transaction.transactionType == .transfer else {
            return transaction.account == account ? transaction.amount : 0
        }
        
        if transaction.account == account {
            return -transaction.amount
        }
        
        if transaction.transferAccount == account {
            return transaction.amount
        }
        
        return 0
    }
    
    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { transactionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    transactionPendingDeletion = nil
                }
            }
        )
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transaction.delete(in: modelContext)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete transaction: \(error)")
        }
        transactionPendingDeletion = nil
        rowOffsets[transaction.id] = 0
    }

    func adaptiveCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(cardStrokeColor, lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: 18, y: 8)
    }

    func emptyState(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(primaryTextColor)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }

    func accountTint(for account: Account) -> Color {
        account.accountType == .credit ? Color(hex: "#F5A623") : Color(hex: "#28B36E")
    }

    func accountSymbol(for account: Account) -> String {
        if account.accountType == .credit {
            return "creditcard.fill"
        }
        
        if account.name.localizedCaseInsensitiveContains("cash") {
            return "wallet.pass.fill"
        }
        
        return "building.columns.fill"
    }

    func transactionPeerLabel(for transaction: Transaction, in account: Account) -> String {
        if transaction.transactionType == .transfer {
            return transaction.account == account ? transaction.transferAccountName : transaction.accountName
        }
        
        return account.name
    }
}
