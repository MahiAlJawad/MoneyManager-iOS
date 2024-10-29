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
    
    @State private var currencyViewModel = CurrencyModel()
    
    @State private var data: DataResponse?
    @State private var baseCurrency = Locale.current.currency?.identifier ?? ""
    @State private var defaultConversionValue: String = ""
    
    @Binding var savedCurrencies: [String]
    @Binding var isSheetPresented: Bool
    
    private func changeCurrencyConversion() {
        if case .loaded(let data) = currencyViewModel.dataResponse  {
            if baseCurrency == currentCurrencies[0] {
                currencyViewModel.fromCurrency = currentCurrencies[0]
                
                let conversion_rate = data.conversion_rate
                defaultConversionValue = String(conversion_rate)
            } else {
                currencyViewModel.toCurrency = currentCurrencies[1]
                let conversion_rate = 1 / (data.conversion_rate)
                defaultConversionValue = String(conversion_rate)
            }
        }
    }
    
    var body: some View {
        Spacer()
        VStack {
            Picker("picker", selection: $baseCurrency) {
                ForEach(currentCurrencies, id: \.self) {
                    Text("1\($0)=")
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: baseCurrency) {
                changeCurrencyConversion()
            }
            
            switch currencyViewModel.dataResponse {
            case .loaded:
                CustomKeypad(displayedNumber: $defaultConversionValue)
            case .loading:
                ProgressView()
                    .task {
                        currencyViewModel.fromCurrency = currentCurrencies[0]
                        currencyViewModel.toCurrency = currentCurrencies[1]
                        await currencyViewModel.loadData()
                        changeCurrencyConversion()
                    }
            case .failed:
                ContentUnavailableView(
                    "Connection issue",
                    systemImage: "wifi.slash",
                    description: Text("Check your internet connection")
                )
            }
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
