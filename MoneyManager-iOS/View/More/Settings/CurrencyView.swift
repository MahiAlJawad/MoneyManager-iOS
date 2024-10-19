//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    let localeCurrencies = Locale.commonISOCurrencyCodes

    var body: some View {
        Form {
            Section {
                BaseCurrencyView()
                List(localeCurrencies, id: \.self) { currencyCode in
                    HStack {
                        CurrencyCellView(currencyCode: currencyCode)
                    }
                }.applyListItemHeight()
            }
            Section {
                Text("section 2")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Currency", systemImage: "plus") {
                    print("tab bar button is pressed")
                    
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
        }
    }
}

struct CurrencyCellView: View {
    let currencyCode: String
    
    var body: some View {
        HStack {
            let currencyLocale = Locale(identifier: currencyCode)
            let countryCode = String(currencyCode.prefix(2))
            let currencyName = (currencyLocale as NSLocale).displayName(forKey:NSLocale.Key.currencyCode, value: currencyCode)
            
            
            let countryLocale  = NSLocale.current
            let countryName = (countryLocale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            
            
            Text(Currency.countryFlag(countryCode: countryCode))
                .font(.system(size: 50))
            
            VStack(alignment:.leading){
                Text("\(currencyCode)")
                Text(currencyName ?? "")
                    .font(.caption)
                Text(countryName ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    CurrencyView()
}
