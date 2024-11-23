//
//  AddTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import Flow
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
    @FocusState private var focusedField: FocusedField?
    @State private var bgColor = Color.gray.opacity(0.2)
    
    // TODO: Logic needs to update after all data are prepared
    var isSaveButtonEnabled: Bool {
        !addTransactionInfo.amount.isEmpty &&
        addTransactionInfo.account != nil &&
        (addTransactionInfo.category != nil || addTransactionInfo.transferAccount != nil)
    }
    
    var body: some View {
        VStack {
            expenseTypePickerView
            List {
                expenseAmountTextFieldView
                generalSectionView
                moreDetailsSectionView
            }
            .listStyle(.grouped)
            saveButton
        }
        .onLoad {
            focusedField = .amount
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.red)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Templates") {
                    // TODO: Handle templates action
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .navigationTitle("Add Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var saveButton: some View {
        Button {
            do {
                try Transaction.addTransaction(from: addTransactionInfo)
            } catch {
                // TODO: show error alert once the UI is ready
                print("Error: \(error)")
            }
            
            dismiss()
        } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 35)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .disabled(!isSaveButtonEnabled)
    }
    
    var expenseTypePickerView: some View {
        Picker(selection: $addTransactionInfo.transactionType, label: Text("")) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
            Text("Transfer").tag(TransactionType.transfer)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    var expenseAmountTextFieldView: some View {
        Section("Amount") {
            HStack {
                HStack {
                    Text(addTransactionInfo.currency.currencyCode ?? "")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .padding()
                        .frame(height: 30)
                        .background(addTransactionInfo.transactionType.color)
                        .cornerRadius(15)
                }.onTapGesture {
                    router.navigate(
                        to: Destination.currencySelectionView(selectedCurrency: $addTransactionInfo.currency)
                    )
                }
                
                Spacer()
                
                TextField("0", text: $addTransactionInfo.amount)
                    .font(.system(size: 50))
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private func labelView(with label: TransactionLabel) -> some View {
        HStack {
            Text(label.name)
                .foregroundStyle(Color(hex: label.color).getContrastColor)
                .font(.footnote)
                .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
            
            Button {
                guard let indexToDelete = addTransactionInfo.labels.firstIndex(of: label) else {
                    return
                }
                addTransactionInfo.labels.remove(at: indexToDelete)
            } label: {
                Image(systemName: "multiply.circle.fill")
            }
            .buttonStyle(.plain)
            .font(.footnote)
            .foregroundColor(Color(hex: label.color).getContrastColor)
            .padding(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
        }
        .background(Color(hex: label.color))
        .frame(height: 20)
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
    }
    
    var generalSectionView: some View {
        Section("General") {
            HStack {
                Label("Account", systemImage: "banknote")
                Spacer()
                Text(addTransactionInfo.account?.name ?? "Required")
                    .foregroundColor(addTransactionInfo.account == nil ? .red : .gray)
            }
            .disclosureIndicator()
            .applyListItemHeight()
            .onTapGesture {
                router.navigate(
                    to: Destination.accountSelectionView(
                        account: $addTransactionInfo.account,
                        transferAccount: addTransactionInfo.transferAccount
                    )
                )
            }
            
            if addTransactionInfo.transactionType == .transfer {
                HStack {
                    Label {
                        Text("To account")
                    } icon: {
                        Image(systemName: "questionmark.app")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    if let transferAccount = addTransactionInfo.transferAccount {
                        Text(transferAccount.name)
                            .foregroundColor(.gray)
                    } else {
                        Text("Required")
                            .foregroundColor(.red)
                    }
                }
                .disclosureIndicator()
                .applyListItemHeight()
                .onTapGesture {
                    router.navigate(
                        to: Destination.transferAccountSelectionView(
                            account: addTransactionInfo.account,
                            transferAccount: $addTransactionInfo.transferAccount
                        )
                    )
                }
            } else {
                NavigationLink(value: Destination.categorySelectionView(category: $addTransactionInfo.category)) {
                    HStack {
                        Label {
                            Text("Category")
                        } icon: {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        if let category = addTransactionInfo.category {
                            Text(category.name)
                                .foregroundColor(.gray)
                        } else {
                            Text("Required")
                                .foregroundColor(.red)
                        }
                    }
                }.applyListItemHeight()
            }
            
            HStack {
                Label {
                    Text("Date")
                } icon: {
                    Image(systemName: "calendar")
                }
                Spacer()
                DatePicker("",selection: $addTransactionInfo.date, displayedComponents: .date)
                    .labelsHidden()
            }
            .applyListItemHeight()
            
            VStack(alignment: .leading) {
                HStack {
                    Label("Labels", systemImage: "tag")
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            router.navigate(to: .labelSelectionView(selectedLabels: $addTransactionInfo.labels))
                        }
                }
                
                if !addTransactionInfo.labels.isEmpty {
                    HFlow(alignment: .top) {
                        ForEach(addTransactionInfo.labels) { label in
                            labelView(with: label)
                        }
                    }
                    .padding(.init(top: 5, leading: 40, bottom: 0, trailing: 10))
                }
            }
            .applyListItemHeight()
        }
    }
    
    var moreDetailsSectionView: some View {
        Section("More Details") {
            Label {
                TextField("Add your note", text: $addTransactionInfo.note)
                    .clearButton(on: $addTransactionInfo.note)
                    .focused($focusedField, equals: .note)
            } icon: {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
            }.applyListItemHeight()

            NavigationLink(value: Destination.selectPaymentMethodView(paymentMethod: $addTransactionInfo.paymentMethod)) {
                HStack {
                    Label {
                        Text("Payment Type")
                    } icon: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(addTransactionInfo.paymentMethod.description)
                        .foregroundStyle(.gray)
                }
            }.applyListItemHeight()
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
        var labels: [TransactionLabel] = []
        var note: String = ""
        var paymentMethod: PaymentMethod = .cash
    }
}
