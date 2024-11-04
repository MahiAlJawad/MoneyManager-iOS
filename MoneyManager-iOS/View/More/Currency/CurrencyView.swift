//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    @Binding var isAddCurrencyPresent: Bool
    @Binding var savedCurrencies: [Currency]
    
    private func deleteCurrency(indexSet: IndexSet) {
        indexSet.forEach { index in
            savedCurrencies.remove(at: index)
            do {
                let encodedData = try JSONEncoder().encode(savedCurrencies)
                let userDefaults = UserDefaults.standard
                userDefaults.set(encodedData, forKey: "SavedCurrencies")
            } catch {
                print("Failed to save currency data \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                BaseCurrencyView()
                List {
                    ForEach(savedCurrencies, id: \.self) { currency in
                        CurrencyCellView(currencyCode: currency.currencyCode ?? "")
                    }.onDelete(perform: deleteCurrency)
                }
            }
            Section {
                // TODO: will update it into currency settings section
                Text("Currency Settings")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Currency", systemImage: "plus") {
                    isAddCurrencyPresent = true
                }
            }
        }
        .navigationTitle("Currencies")
    }
}

struct BaseCurrencyView: View {
    let baseCurrencyCode = Locale.current.currency?.identifier ?? ""
    
    var body: some View {
        HStack {
            CurrencyCellView(currencyCode: baseCurrencyCode)
            Spacer()
            Text("Base Currency")
                .font(.system(size: 15))
        }
    }
}
