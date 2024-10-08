//
//  AddTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftData
import SwiftUI

enum FocusField {
    case amount
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0 // 0: Expense, 1: Income, 2: Transfer
    @State private var amount: String = ""
    @State private var account: String? = "Cash"
    @State private var category: Category?
    @State private var date: Date = Date()
    @State private var toNote: String = ""
    @State private var paymentMethod: PaymentType = .init(category: .cash)
    
    @FocusState private var focusField: FocusField?
    
    @State private var bgColor = Color.gray.opacity(0.2)

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                    .padding()
                    
                    Spacer()
                    
                    Text("Add Transaction")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Templates") {
                        // TODO: Handle templates action
                    }
                    .foregroundStyle(.black)
                    .padding()
                }
                .background(bgColor)
                
                Picker(selection: $selectedTab, label: Text("")) {
                    Text("Expense").tag(0)
                    Text("Income").tag(1)
                    Text("Transfer").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                HStack {
                    Text("BDT")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .padding()
                        .frame(height: 30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    
                    Spacer()
                    
                    TextField("0", text: $amount)
                        .font(.system(size: 50))
                        .multilineTextAlignment(.trailing)
                        .focused($focusField, equals: .amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                focusField = .amount
                            }
                        }
                }
                .padding(.horizontal)
            }.background(bgColor)
            
            List {
                // GENERAL SECTION
                Section(header: Text("General").textCase(.uppercase)) {
                    NavigationLink(destination: AccountSelectionView(selectedAccount: $account)) {
                        HStack {
                            Image(systemName: "banknote")
                                .foregroundColor(.blue)
                            Text("Account")
                            Spacer()
                            Text(account ?? "")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: CategorySelectionView(selectedCategory: $category)) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                            Text("Category")
                            Spacer()
                            if let category {
                                Text(category.name)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Required")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    DatePicker(selection: $date, displayedComponents: .date) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Date & Time")
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: LabelSelectionView()) {
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
                
                // MORE DETAIL SECTION
                Section(header: Text("More details").textCase(.uppercase)) {
                    NavigationLink(destination: AddNoteView(notes: $toNote)) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                            Text("Note")
                            Spacer()
                            Text(toNote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: PaymentTypeView(payment: $paymentMethod)) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                            Text("Payment Type")
                            Spacer()
                            Text(paymentMethod.category.description)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // TODO: Add location
                    NavigationLink(destination: LabelSelectionView()) {
                        HStack {
                            Image(systemName: "location.app")
                            Text("Add Location")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .padding(.top, -10)
            
            Spacer()
        }
    }
}

struct LabelSelectionView: View {
    var body: some View {
        Text("Select Labels")
    }
}
