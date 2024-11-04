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
    
    var baseCurrency = Currency.baseCurrency
    
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
            currencies = Currency.loadCurrencyData()
        }
    }
}
