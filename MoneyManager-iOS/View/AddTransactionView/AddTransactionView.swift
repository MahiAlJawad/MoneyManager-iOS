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
    @State private var amountExpression = ""
    @State private var isAmountKeyboardPresented = false
    @State private var presentAddAccountView = false
    @State private var presentAddCurrencyView = false
    @State private var currencyRouter = MoreTabView.Router()
    @State private var savedCurrencies: [Currency] = []
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
        .safeAreaInset(edge: .bottom) {
            if isAmountKeyboardPresented {
                amountKeyboardView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onLoad {
            refreshDisplayedAmount()
            presentAmountKeyboard()
        }
        .onChange(of: addTransactionInfo.transactionType) { _, newType in
            if newType == .transfer {
                addTransactionInfo.category = nil
            } else {
                addTransactionInfo.transferAccount = nil
            }
            
            refreshDisplayedAmount()
        }
        .onChange(of: focusedField) { _, newValue in
            if newValue == .note {
                isAmountKeyboardPresented = false
            }
        }
        .animation(.snappy(duration: 0.24), value: isAmountKeyboardPresented)
        .background(
            KeyboardDismissTapView {
                focusedField = nil
                isAmountKeyboardPresented = false
            }
        )
        .sheet(isPresented: $presentAddAccountView) {
            NavigationView {
                AddAccountView()
            }
        }
        .sheet(isPresented: $presentAddCurrencyView) {
            NavigationStack(path: $currencyRouter.secondNavigationPath) {
                AddCurrencyView(
                    isSheetPresented: $presentAddCurrencyView,
                    newCurrencies: $savedCurrencies
                )
                .navigationDestination(for: MoreTabView.Router.Destination2.self) { destination in
                    switch destination {
                    case .currencyConversionView(let selectedCurrency):
                        CurrencyDetailsView(
                            currentCurrencies: [Currency.baseCurrencyCode, selectedCurrency],
                            savedNewCurrencies: $savedCurrencies,
                            isSheetPresented: $presentAddCurrencyView
                        )
                    }
                }
            }
            .environment(currencyRouter)
        }
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
                currencyMenuButton
                
                Spacer(minLength: 12)
                
                Button {
                    presentAmountKeyboard()
                } label: {
                    Text(displayedAmount)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .font(.system(size: 52, weight: .regular))
                        .foregroundStyle(addTransactionInfo.transactionType.color)
                        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, minHeight: 88, maxHeight: 88, alignment: .leading)
            .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
    
    private var amountKeyboardView: some View {
        AmountKeyboardView(onKeyTap: handleAmountKeyboardKey)
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
    
    private var availableCurrencies: [Currency] {
        var currencies = [Currency.baseCurrency]
        let savedCurrencies = Currency.loadCurrencyData()
        let savedCurrencyCodes = Set(currencies.compactMap(\.currencyCode))
        
        currencies.append(
            contentsOf: savedCurrencies.filter { currency in
                guard let currencyCode = currency.currencyCode else {
                    return false
                }
                
                return !savedCurrencyCodes.contains(currencyCode)
            }
        )
        
        return currencies
    }
    
    private var currencyMenuButton: some View {
        HStack(spacing: 2) {
            Text(addTransactionInfo.currency.currencyCode ?? "")
                .lineLimit(1)
                .frame(width: 42, height: 36)
            
            currencyMenuTrigger
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
        .frame(width: 76, height: 36)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var currencyMenuTrigger: some View {
        Menu {
            ForEach(availableCurrencies, id: \.currencyCode) { currency in
                Button {
                    addTransactionInfo.currency = currency
                } label: {
                    Label(currencyMenuTitle(for: currency), systemImage: "coloncurrencysign.circle")
                }
            }
            
            Divider()
            
            Button {
                savedCurrencies = Currency.loadCurrencyData()
                currencyRouter.navigateToSecondRoot()
                presentAddCurrencyView = true
            } label: {
                Label("Add Currency", systemImage: "plus.circle")
            }
        } label: {
            dropdownButtonIcon(backgroundColor: Color(uiColor: .systemBackground).opacity(0.7))
        }
        .buttonStyle(.plain)
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
            
            Divider()
            
            Button {
                presentAddAccountView = true
            } label: {
                Label("Add Account", systemImage: "plus.circle")
            }
        } label: {
            dropdownButtonIcon()
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
            dropdownButtonIcon()
        }
        .buttonStyle(.plain)
    }
    
    private func dropdownButtonIcon(backgroundColor: Color = Color(uiColor: .tertiarySystemFill)) -> some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .foregroundStyle(.primary)
            .frame(width: 30, height: 30)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(uiColor: .separator).opacity(0.45), lineWidth: 0.5)
            )
            .contentShape(Rectangle())
    }
    
    private func balanceStatusText(for balance: Double) -> String {
        let balanceText = abs(balance).formatted(.number.precision(.fractionLength(0...2)))
        return balance < 0 ? "\(balanceText) DR." : "\(balanceText) CR"
    }
    
    private func currencyMenuTitle(for currency: Currency) -> String {
        guard let currencyCode = currency.currencyCode else {
            return ""
        }

        let currencyLocale = Locale(identifier: currencyCode)
        return currency.currencyName ??
        (currencyLocale as NSLocale).displayName(forKey: .currencyCode, value: currencyCode) ??
        currencyCode
    }
    
    private func saveTransaction() {
        do {
            var transactionInfo = addTransactionInfo
            transactionInfo.amount = AmountExpressionCalculator.evaluatedAmountValue(from: amountExpression)
            
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
    
    private func handleAmountKeyboardKey(_ key: AmountKeyboardKey) {
        switch key {
        case .digit(let digit):
            amountExpression = AmountExpressionCalculator.appendingDigit(digit, to: amountExpression)
        case .decimal:
            amountExpression = AmountExpressionCalculator.appendingDecimalPoint(to: amountExpression)
        case .add, .subtract, .multiply, .divide:
            if let operatorSymbol = key.operatorSymbol {
                amountExpression = AmountExpressionCalculator.appendingOperator(operatorSymbol, to: amountExpression)
            }
        case .percent:
            amountExpression = AmountExpressionCalculator.applyingPercentToCurrentNumber(in: amountExpression)
        case .clear:
            amountExpression = ""
        case .backspace:
            if !amountExpression.isEmpty {
                amountExpression.removeLast()
            }
        case .equals:
            commitAmountExpression()
        case .done:
            commitAmountExpression()
            focusedField = nil
            isAmountKeyboardPresented = false
            return
        }
        
        updateAmountFromExpression()
        keepAmountKeyboardPresented()
    }
    
    private func presentAmountKeyboard() {
        focusedField = nil
        keepAmountKeyboardPresented()
    }
    
    private func keepAmountKeyboardPresented() {
        DispatchQueue.main.async {
            isAmountKeyboardPresented = true
        }
    }
    
    private func commitAmountExpression() {
        amountExpression = AmountExpressionCalculator.evaluatedExpression(from: amountExpression)
        updateAmountFromExpression()
    }
    
    private func updateAmountFromExpression() {
        addTransactionInfo.amount = AmountExpressionCalculator.evaluatedAmountValue(from: amountExpression)
        displayedAmount = AmountExpressionCalculator.displayText(for: amountExpression)
    }
    
    private func refreshDisplayedAmount() {
        amountExpression = addTransactionInfo.amount
        updateAmountFromExpression()
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
