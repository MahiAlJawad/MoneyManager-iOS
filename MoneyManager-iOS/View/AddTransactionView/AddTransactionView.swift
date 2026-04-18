//
//  AddTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftData
import SwiftUI
import UIKit

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
        .background(SegmentedPickerTintUpdater(tintColor: UIColor(addTransactionInfo.transactionType.color)))
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
    
    var generalSectionView: some View {
        Section {
            selectableRow(
                title: addTransactionInfo.transactionType == .transfer ? "From Account" : "Account",
                value: addTransactionInfo.account?.name ?? "Required",
                valueStyle: addTransactionInfo.account == nil ? .required : .secondary,
                icon: "person.circle.fill",
                iconColor: .blue
            ) {
                router.navigate(
                    to: Destination.accountSelectionView(
                        account: $addTransactionInfo.account,
                        transferAccount: addTransactionInfo.transferAccount
                    )
                )
            }
            
            if addTransactionInfo.transactionType == .transfer {
                selectableRow(
                    title: "To Account",
                    value: addTransactionInfo.transferAccount?.name ?? "Required",
                    valueStyle: addTransactionInfo.transferAccount == nil ? .required : .secondary,
                    icon: "person.circle.fill",
                    iconColor: .cyan
                ) {
                    router.navigate(
                        to: Destination.transferAccountSelectionView(
                            account: addTransactionInfo.account,
                            transferAccount: $addTransactionInfo.transferAccount
                        )
                    )
                }
            } else {
                NavigationLink(value: Destination.categorySelectionView(category: $addTransactionInfo.category)) {
                    rowContent(
                        title: "Category",
                        value: addTransactionInfo.category?.name ?? "Required",
                        valueStyle: addTransactionInfo.category == nil ? .required : .secondary,
                        icon: "star.fill",
                        iconColor: .orange
                    )
                }
                .applyListItemHeight()
            }
            
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
        }
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

private struct KeyboardDismissTapView: UIViewRepresentable {
    let onTap: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onTap = onTap
        
        DispatchQueue.main.async {
            context.coordinator.attachRecognizer(to: uiView.window)
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.detachRecognizer()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onTap: () -> Void
        private weak var attachedView: UIView?
        private lazy var recognizer: UITapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            return recognizer
        }()
        
        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }
        
        func attachRecognizer(to view: UIView?) {
            guard let view, attachedView !== view else {
                return
            }
            
            detachRecognizer()
            view.addGestureRecognizer(recognizer)
            attachedView = view
        }
        
        func detachRecognizer() {
            attachedView?.removeGestureRecognizer(recognizer)
            attachedView = nil
        }
        
        @objc func handleTap() {
            onTap()
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            
            while let currentView = view {
                if currentView is UIControl || currentView is UITextView {
                    return false
                }
                
                view = currentView.superview
            }
            
            return true
        }
    }
}

private struct SegmentedPickerTintUpdater: UIViewRepresentable {
    let tintColor: UIColor
    
    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let segmentedControl = uiView.enclosingSubview(of: UISegmentedControl.self) else {
                return
            }
            
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
            
            UIView.animate(withDuration: 0.2) {
                segmentedControl.selectedSegmentTintColor = tintColor
            }
        }
    }
}

private extension UIView {
    func enclosingSubview<T: UIView>(of type: T.Type) -> T? {
        var container: UIView? = self
        
        while let view = container {
            if let match = view.firstSubview(of: type) {
                return match
            }
            
            container = view.superview
        }
        
        return nil
    }
    
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }
        
        for subview in subviews {
            if let match = subview.firstSubview(of: type) {
                return match
            }
        }
        
        return nil
    }
}

extension AddTransactionView {
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
    typealias PaymentMethod = Transaction.PaymentMethod
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
        var paymentMethod: PaymentMethod = .cash
    }
}
