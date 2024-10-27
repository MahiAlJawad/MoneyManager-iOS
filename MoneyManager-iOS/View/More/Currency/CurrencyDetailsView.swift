//
//  CurrencyDetailsView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 24/10/24.
//

import SwiftUI

struct CurrencyDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MoreTabView.Router.self) private var router
    
    let currentCurrencies: [String]
    
    @State private var baseCurrency = Locale.current.currency?.identifier ?? ""
    @State private var defaultValue: String = "130"
    
    @Binding var savedCurrencies: [String]
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        Spacer()
        VStack {
            Picker("picker", selection: $baseCurrency) {
                ForEach(currentCurrencies, id: \.self) {
                    Text("1\($0)=")
                }
            }
            .pickerStyle(.segmented)
            Text("selected currency is \(baseCurrency)")
            
            // TODO: Need to take data from API
            CustomKeypad(displayedNumber: $defaultValue)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    savedCurrencies.append(currentCurrencies[1])
                    UserDefaults.standard.set(savedCurrencies, forKey: "SavedCurrencies")
                    dismiss()
                    isSheetPresented = false
                }
            }
        }
    }
}

struct CustomKeypad: View {
    @Binding var displayedNumber: String
    @State private var numericValue: Double? = 0.0
    
    let buttons = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(displayedNumber)
                .font(.largeTitle)
                .frame(height: 30)
            
            Spacer()
            
            Grid {
                ForEach(0..<buttons.count, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(buttons[rowIndex], id: \.self) { number in
                            Keypadbutton(label: number) {
                                displayedNumber += number
                            }
                        }
                    }
                }
                
                GridRow {
                    Keypadbutton(label: ".") {
                        displayedNumber += "."
                    }
                    Keypadbutton(label: "0") {
                        displayedNumber += "0"
                    }
                    DeleteButton {
                        if !displayedNumber.isEmpty {
                            displayedNumber.removeLast()
                        }
                    }
                }
            }
        }
    }
}

struct Keypadbutton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.title)
                .frame(width: 120, height: 50)
                .background(in: Rectangle())
        }
        .buttonStyle(.plain)
        .shadow(radius: 1)
    }
}

struct DeleteButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.title)
                .frame(width: 120, height: 50)
                .background(in: Rectangle())
        }
        .buttonStyle(.plain)
        .shadow(radius: 1)
    }
}


#Preview {
    CurrencyDetailsView(currentCurrencies: ["BDT", "USD"], savedCurrencies: .constant(["BDT"]), isSheetPresented: .constant(true))
}
