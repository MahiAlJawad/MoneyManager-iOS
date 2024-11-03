//
//  CurrencySelectionView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 4/11/24.
//

import SwiftUI

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCurrency: Currency
    @State private var currencies: [Currency] = []
    
    private func loadData() {
        if let savedData = UserDefaults.standard.object(forKey: "SavedCurrencies") as? Data {
            
            do {
                let savedCurrencyData = try JSONDecoder().decode([Currency].self, from: savedData)
                currencies = savedCurrencyData
            } catch {
                print("Failed to convert Data to Currency \(error.localizedDescription)")
            }
        }
    }
    
    var baseCurrency: Currency = .init(currencyCode: Locale.current.currency?.identifier ?? "", conversionRate: 1.0)
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(baseCurrency.currencyCode ?? "")
                    Spacer()
                    Text("Base Currency")
                        .font(.system(size: 15))
                }
                .makeFullWidthListItemTappable {
                    selectedCurrency = baseCurrency
                    dismiss()
                }
                
                List(currencies, id: \.self) { item in
                    HStack {
                        Text(item.currencyCode ?? "")
                    }
                    .makeFullWidthListItemTappable {
                        selectedCurrency = item
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
}
