//
//  AddTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftData
import SwiftUI

struct AddTransactionView: View {
    private typealias Destination = TransactionTabView.Router.Destination
    
    enum FocusedField {
        case amount, note
    }
    
    @Environment(TransactionTabView.Router.self) private var router
    
    @Environment(\.dismiss) private var dismiss
    @State private var addTransactionInfo = AddTransactionInfo()
    @State private var displayedAmount = "-0"
    @FocusState private var focusedField: FocusedField?
    
    @Query(sort: [.init(\Account.name)])
    private var accounts: [Account]
    
    @Query(sort: [.init(\Transaction.date, order: .reverse)])
    private var transactions: [Transaction]
    
    private let quickCategoryLimit = 5
    
    // TODO: Logic needs to update after all data are prepared
    var isSaveButtonEnabled: Bool {
        !addTransactionInfo.amount.isEmpty &&
        addTransactionInfo.account != nil &&
        (addTransactionInfo.category != nil || addTransactionInfo.transferAccount != nil)
    }
    
    var amountPrefix: String {
        switch addTransactionInfo.transactionType {
        case .expense:
            "-"
        case .income:
            "+"
        case .transfer:
            ""
        }
    }
    
    var body: some View {
        List {
            expenseTypePickerView
            expenseAmountTextFieldView
            generalSectionView
            moreDetailsSectionView
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollDismissesKeyboard(.interactively)
        .onLoad {
            refreshDisplayedAmount()
            focusedField = .amount
        }
        .onChange(of: addTransactionInfo.transactionType) { _, newType in
            if newType == .transfer {
                addTransactionInfo.category = nil
            } else {
                addTransactionInfo.transferAccount = nil
            }
            
            refreshDisplayedAmount()
        }
        .onChange(of: displayedAmount) { _, newValue in
            updateAmount(from: newValue)
        }
        .background(
            KeyboardDismissTapView {
                focusedField = nil
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.red)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", action: saveTransaction)
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .tint(addTransactionInfo.transactionType.color)
                    .disabled(!isSaveButtonEnabled)
                    .id(addTransactionInfo.transactionType)
            }
        }
        .navigationTitle("Add Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var expenseTypePickerView: some View {
        Picker(selection: $addTransactionInfo.transactionType, label: Text("Transaction Type")) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
            Text("Transfer").tag(TransactionType.transfer)
        }
        .pickerStyle(.segmented)
        .background(SegmentedPickerTintUpdater(tintColor: addTransactionInfo.transactionType.color))
        .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    var expenseAmountTextFieldView: some View {
        Section {
            HStack(spacing: 12) {
                Button {
                    router.navigate(
                        to: Destination.currencySelectionView(selectedCurrency: $addTransactionInfo.currency)
                    )
                } label: {
                    HStack(spacing: 4) {
                        Text(addTransactionInfo.currency.currencyCode ?? "")
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer(minLength: 12)
                
                TextField("", text: $displayedAmount)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.decimalPad)
                    .tint(addTransactionInfo.transactionType.color)
                    .font(.system(size: 52, weight: .regular))
                    .foregroundStyle(addTransactionInfo.transactionType.color)
                    .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88, alignment: .leading)
            .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
    
    @ViewBuilder
    var generalSectionView: some View {
        Section {
            accountDropdownRow(
                title: addTransactionInfo.transactionType == .transfer ? "From Account" : "Account",
                icon: "person.circle.fill",
                iconColor: .blue,
                selectedAccount: $addTransactionInfo.account,
                excluding: addTransactionInfo.transferAccount
            )
        } header: {
            sectionSpacerHeader
        }
        
        if addTransactionInfo.transactionType == .transfer {
            Section {
                accountDropdownRow(
                    title: "To Account",
                    icon: "person.circle.fill",
                    iconColor: .cyan,
                    selectedAccount: $addTransactionInfo.transferAccount,
                    excluding: addTransactionInfo.account
                )
            }
        } else {
            Section {
                categoryDropdownButton
            }
        }
        
        Section {
            HStack(spacing: 12) {
                rowIcon(systemName: "calendar", color: .pink)
                
                Text("Date")
                    .foregroundStyle(.primary)
                
                Spacer()
                
                DatePicker("", selection: $addTransactionInfo.date, displayedComponents: .date)
                    .labelsHidden()
            }
            .applyListItemHeight()
        }
    }
    
    var moreDetailsSectionView: some View {
        Section {
            HStack(alignment: .center, spacing: 12) {
                rowIcon(systemName: "note.text", color: .green)
                
                TextField("Add note", text: $addTransactionInfo.note, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($focusedField, equals: .note)
            }
            .applyListItemHeight()
        } header: {
            sectionSpacerHeader
        }
    }
    
    private var sectionSpacerHeader: some View {
        Color.clear
            .frame(height: 8)
            .accessibilityHidden(true)
    }
    
    private var quickCategories: [CategoryMenuItem] {
        var categoryItems: [CategoryMenuItem] = []
        var addedCategoryNames = Set<String>()
        
        for transaction in transactions {
            guard let category = transaction.transactionCategory,
                  addedCategoryNames.insert(category.name).inserted else {
                continue
            }
            
            categoryItems.append(CategoryMenuItem(category: category))
            
            if categoryItems.count == quickCategoryLimit {
                return categoryItems
            }
        }
        
        for category in Transaction.allMainCategories {
            guard addedCategoryNames.insert(category.name).inserted else {
                continue
            }
            
            categoryItems.append(CategoryMenuItem(category: category))
            
            if categoryItems.count == quickCategoryLimit {
                break
            }
        }
        
        return categoryItems
    }
    
    private func availableAccounts(excluding excludedAccount: Account?) -> [Account] {
        guard let excludedAccountID = excludedAccount?.id else {
            return accounts
        }
        
        return accounts.filter { $0.id != excludedAccountID }
    }
    
    private func accountDropdownRow(
        title: String,
        icon: String,
        iconColor: Color,
        selectedAccount: Binding<Account?>,
        excluding excludedAccount: Account?
    ) -> some View {
        HStack(spacing: 12) {
            rowIcon(systemName: icon, color: iconColor)
            
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            accountSummaryView(for: selectedAccount.wrappedValue)
            
            accountMenuButton(selectedAccount: selectedAccount, excluding: excludedAccount)
        }
        .applyListItemHeight()
    }
    
    @ViewBuilder
    private func accountSummaryView(for account: Account?) -> some View {
        if let account {
            VStack(alignment: .trailing, spacing: 2) {
                Text(account.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text("Balance \(balanceStatusText(for: account.accountBalance))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } else {
            Text("Select")
                .foregroundStyle(RowValueStyle.required.color)
                .lineLimit(1)
        }
    }
    
    private func accountMenuButton(
        selectedAccount: Binding<Account?>,
        excluding excludedAccount: Account?
    ) -> some View {
        Menu {
            ForEach(availableAccounts(excluding: excludedAccount)) { account in
                Button {
                    selectedAccount.wrappedValue = account
                } label: {
                    Label(account.name, systemImage: account.iconName)
                }
            }
        } label: {
            Image(systemName: "chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var categoryDropdownButton: some View {
        HStack(spacing: 12) {
            rowIcon(systemName: "star.fill", color: .orange)
            
            Text("Category")
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(addTransactionInfo.category?.name ?? "Select")
                .foregroundStyle(addTransactionInfo.category == nil ? RowValueStyle.required.color : RowValueStyle.secondary.color)
                .lineLimit(1)
            
            categoryMenuButton
        }
        .applyListItemHeight()
    }
    
    private var categoryMenuButton: some View {
        Menu {
            ForEach(quickCategories) { item in
                Button {
                    addTransactionInfo.category = item.category
                } label: {
                    Label(item.category.name, systemImage: item.category.icon)
                }
            }
            
            Divider()
            
            Button {
                router.navigate(to: Destination.categorySelectionView(category: $addTransactionInfo.category))
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        } label: {
            Image(systemName: "chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func balanceStatusText(for balance: Double) -> String {
        let balanceText = abs(balance).formatted(.number.precision(.fractionLength(0...2)))
        return balance < 0 ? "\(balanceText) DR." : "\(balanceText) CR"
    }
    
    private func saveTransaction() {
        do {
            var transactionInfo = addTransactionInfo
            transactionInfo.amount = normalizedAmountValue(from: displayedAmount)
            
            try Transaction.addTransaction(from: transactionInfo)
        } catch {
            // TODO: show error alert once the UI is ready
            print("Error: \(error)")
            return
        }
        
        dismiss()
    }
    
    private func selectableRow(
        title: String,
        value: String,
        valueStyle: RowValueStyle,
        icon: String,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            rowContent(title: title, value: value, valueStyle: valueStyle, icon: icon, iconColor: iconColor)
        }
        .buttonStyle(.plain)
        .disclosureIndicator()
        .applyListItemHeight()
    }
    
    private func rowContent(
        title: String,
        value: String,
        valueStyle: RowValueStyle,
        icon: String,
        iconColor: Color
    ) -> some View {
        HStack(spacing: 12) {
            rowIcon(systemName: icon, color: iconColor)
            
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(valueStyle.color)
                .lineLimit(1)
        }
    }
    
    private func rowIcon(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
            
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 30, height: 30)
    }
    
    private func updateAmount(from text: String) {
        let amountValue = normalizedAmountValue(from: text)
        addTransactionInfo.amount = amountValue
        
        let formattedAmount = formattedDisplayedAmount(for: amountValue)
        if displayedAmount != formattedAmount {
            displayedAmount = formattedAmount
        }
    }
    
    private func refreshDisplayedAmount() {
        displayedAmount = formattedDisplayedAmount(for: addTransactionInfo.amount)
    }
    
    private func formattedDisplayedAmount(for amount: String) -> String {
        "\(amountPrefix)\(amount.isEmpty ? "0" : amount)"
    }
    
    private func normalizedAmountValue(from text: String) -> String {
        var amount = ""
        var hasDecimalPoint = false
        
        for character in text {
            if character.isNumber {
                amount.append(character)
            } else if character == ".", !hasDecimalPoint {
                amount.append(character)
                hasDecimalPoint = true
            }
        }
        
        while amount.count > 1,
              amount.first == "0",
              amount[amount.index(after: amount.startIndex)] != "." {
            amount.removeFirst()
        }
        
        if amount == "." {
            amount = "0."
        }
        
        return amount == "0" ? "" : amount
    }
}

extension AddTransactionView {
    fileprivate struct CategoryMenuItem: Identifiable {
        let category: Category
        
        var id: String {
            category.name
        }
    }
    
    fileprivate enum RowValueStyle {
        case required
        case secondary
        
        var color: Color {
            switch self {
            case .required:
                .red
            case .secondary:
                .secondary
            }
        }
    }
}

extension AddTransactionView {
    typealias TransactionType = Transaction.TransactionType
    
    struct AddTransactionInfo {
        var transactionType: TransactionType = .expense
        var currency: Currency = .init(currencyCode: Locale.current.currency?.identifier ?? "", conversionRate: 1.0)
        var amount: String = ""
        var account: Account?
        var transferAccount: Account?
        var category: Category?
        var date: Date = Date()
        var note: String = ""
    }
}
