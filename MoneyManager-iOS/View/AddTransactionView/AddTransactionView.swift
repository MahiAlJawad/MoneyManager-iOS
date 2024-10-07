//
//  AddTransactionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/10/24.
//

import SwiftUI

struct AddTransactionView: View {
    @State private var selectedTab = 0 // 0: Expense, 1: Income, 2: Transfer
    @State private var amount: String = ""
    @State private var account: String? = "Cash"
    @State private var toAccount: String? = nil
    @State private var dateTime: Date = Date()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Handle cancel action
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                Text("Add Transaction")
                    .font(.headline)

                Spacer()

                Button(action: {
                    // Handle templates action
                }) {
                    Text("Templates")
                        .foregroundColor(.black)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.8))

            Picker(selection: $selectedTab, label: Text("")) {
                Text("Expense").tag(0)
                Text("Income").tag(1)
                Text("Transfer").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            HStack {
                Text("BDT")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                TextField("0", text: $amount)
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .padding()
            }
            .padding(.horizontal)

            List {
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

                NavigationLink(destination: AccountSelectionView(selectedAccount: $toAccount)) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                        Text("To account")
                        Spacer()
                        if let toAccount = toAccount {
                            Text(toAccount)
                                .foregroundColor(.gray)
                        } else {
                            Text("Required")
                                .foregroundColor(.red)
                        }
                    }
                }

                DatePicker(selection: $dateTime, displayedComponents: .date) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Date & Time")
                        Spacer()
                        Text("\(dateTime.formatted())")
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: LabelSelectionView()) {
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.gray)
                        Text("Labels")
                        Spacer()
                        Text("Add label")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .padding(.top, -10)

            Spacer()

            NumberPad(amount: $amount)
                .padding(.bottom, 10)
        }
    }
}

struct NumberPad: View {
    @Binding var amount: String

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<3) { row in
                HStack(spacing: 10) {
                    ForEach(1..<4) { column in
                        let number = row * 3 + column
                        Button(action: {
                            amount.append("\(number)")
                        }) {
                            Text("\(number)")
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 1)
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                Button(action: {
                    amount.append(".")
                }) {
                    Text(".")
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }

                Button(action: {
                    amount.append("0")
                }) {
                    Text("0")
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }

                Button(action: {
                    if !amount.isEmpty {
                        amount.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left")
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
            }
        }
        .padding()
    }
}

struct AccountSelectionView: View {
    @Binding var selectedAccount: String?
    var body: some View {
        Text("Select an Account")
    }
}

struct LabelSelectionView: View {
    var body: some View {
        Text("Select Labels")
    }
}

#Preview {
    AddTransactionView()
}
