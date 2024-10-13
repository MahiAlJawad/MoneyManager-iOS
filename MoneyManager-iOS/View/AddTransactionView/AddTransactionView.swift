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
    @FocusState private var focusedField: FocusedField?
    @State private var bgColor = Color.gray.opacity(0.2)
    
    // TODO: Logic needs to update after all data are prepared
    var isSaveButtonEnabled: Bool {
        !addTransactionInfo.amount.isEmpty
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
        .listStyle(InsetGroupedListStyle())
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
            // Save button action
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
                Text("BDT")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .padding()
                    .frame(height: 30)
                    .background(addTransactionInfo.transactionType.color)
                    .cornerRadius(15)
                
                Spacer()
                
                TextField("0", text: $addTransactionInfo.amount)
                    .font(.system(size: 50))
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.decimalPad)
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .never
                    }
            }
        }
    }
    
    var generalSectionView: some View {
        Section("General") {
            NavigationLink(value: Destination.accountSelectionView(account: $addTransactionInfo.account)) {
                HStack {
                    Label("Account", systemImage: "banknote")
                    Spacer()
                    Text(addTransactionInfo.account?.accountName ?? "Required")
                        .foregroundColor(addTransactionInfo.account == nil ? .red : .gray)
                }
            }.applyListItemHeight()
            
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
            
            HStack {
                Label("Labels", systemImage: "tag")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        router.navigate(to: .labelSelectionView)
                    }
            }
            .applyListItemHeight()
        }
    }
    
    var moreDetailsSectionView: some View {
        Section("More Details") {
            HStack {
                Label {
                    TextField("Add your note", text: $addTransactionInfo.toNote)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .note)
                        .onAppear {
                            UITextField.appearance().clearButtonMode = .whileEditing
                        }
                } icon: {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue)
                }
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
        var amount: String = ""
        var account: Account?
        var transferAccount: Account?
        var category: Category?
        var date: Date = Date()
        var toNote: String = ""
        var paymentMethod: PaymentMethod = .cash
    }
}

struct LabelSelectionView: View {
    var body: some View {
        Text("Select Labels")
    }
}
