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
    
    // Not being used till now but you can navigate using `router.navigateTo(Destination)
    @Environment(TransactionTabView.Router.self) private var router
    
    @Environment(\.dismiss) private var dismiss
    @State private var addTransactionInfo = AddTransactionInfo()
    @FocusState private var focusField: FocusField?
    @State private var bgColor = Color.gray.opacity(0.2)
    
    var body: some View {
        VStack {
            VStack {
                expenseTypePickerView
                    .padding()
                expenseAmountTextFieldView
                    .padding(.horizontal)
            }
            .background(bgColor)
            
            List {
                generalSectionView
                moreDetailsSectionView
            }
            .listStyle(InsetGroupedListStyle())
            .padding(.top, -10)
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
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var expenseTypePickerView: some View {
        Picker(selection: $addTransactionInfo.transactionType, label: Text("")) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
            Text("Transfer").tag(TransactionType.transfer)
        }
        .pickerStyle(.segmented)
    }
    
    var expenseAmountTextFieldView: some View {
        HStack {
            Text("BDT")
                .font(.system(size: 15))
                .fontWeight(.medium)
                .padding()
                .frame(height: 30)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
            
            Spacer()
            
            TextField("0", text: $addTransactionInfo.amount)
                .font(.system(size: 50))
                .multilineTextAlignment(.trailing)
                .focused($focusField, equals: .amount)
                .keyboardType(.decimalPad)
                .padding()
                .onAppear {
                    withAnimation {
                        focusField = .amount
                    }
                }
        }
    }
    
    var generalSectionView: some View {
        Section("General") {
            NavigationLink(value: Destination.accountSelectionView(account: $addTransactionInfo.account)) {
                HStack {
                    Image(systemName: "banknote")
                        .foregroundColor(.blue)
                    Text("Account")
                    Spacer()
                    Text(addTransactionInfo.account?.accountName ?? "Required")
                        .foregroundColor(addTransactionInfo.account == nil ? .red : .gray)
                }
            }
            
            NavigationLink(value: Destination.categorySelectionView(category: $addTransactionInfo.category)) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                    Text("Category")
                    Spacer()
                    if let category = addTransactionInfo.category {
                        Text(category.name)
                            .foregroundColor(.gray)
                    } else {
                        Text("Required")
                            .foregroundColor(.red)
                    }
                }
            }
            
            DatePicker(selection: $addTransactionInfo.date, displayedComponents: .date) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date & Time")
                    Spacer()
                }
            }
            
            NavigationLink(value: Destination.labelSelectionView) {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.gray)
                    Text("Labels")
                    Spacer()
                    Text("Add Label")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var moreDetailsSectionView: some View {
        Section("More Details") {
            NavigationLink(value: Destination.addNoteView(note: $addTransactionInfo.toNote)) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue)
                    Text("Note")
                    Spacer()
                    Text(addTransactionInfo.toNote)
                        .foregroundColor(.gray)
                }
            }
            
            NavigationLink(value: Destination.selectPaymentMethodView(paymentMethod: $addTransactionInfo.paymentMethod)) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                    Text("Payment Type")
                    Spacer()
                    Text(addTransactionInfo.paymentMethod.description)
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}


extension AddTransactionView {
    typealias PaymentMethod = Transaction.PaymentMethod
    typealias TransactionType = Transaction.TransactionType
    
    enum FocusField {
        case amount
    }
    
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
