//
//  CurrencyDetailsView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 24/10/24.
//

import SwiftUI

struct CurrencyDetailsView: View {
    let currentCurrencies: [String]
    @State private var baseCurrency = Locale.current.currency?.identifier ?? ""
    @State private var defaultValue: String = "120.3"
    @Binding var savedCurrencies: [String]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Spacer()
        VStack {
            Picker("picker", selection: $baseCurrency) {
                ForEach(currentCurrencies, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            Text("selected number is \(baseCurrency)")
            CustomKeypad(displayedNumber: $defaultValue)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    print("save button tapped")
                    savedCurrencies.append(currentCurrencies[1])
                    UserDefaults.standard.set(savedCurrencies, forKey: "SavedCurrencies")
                    dismiss()
                    dismiss()
                   // router.navigateToRoot2()
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
            //Text(numericValue)
            
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
                                
                                print("shakib1 \(Double(displayedNumber))")
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
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.gray, in: Circle())
        }
        
    }
}

struct DeleteButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.gray, in: Circle())
                .tint(.primary)
        }
        
        
    }
}


#Preview {
    CurrencyDetailsView(currentCurrencies: ["BDT", "USD"], savedCurrencies: .constant(["BDT"]))
}
