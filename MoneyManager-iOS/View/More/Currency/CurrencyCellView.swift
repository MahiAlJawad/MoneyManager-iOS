//
//  CurrencyCellView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyCellView: View {
    let currencyCode: String
    
    var body: some View {
        HStack {
            let currencyLocale = Locale(identifier: currencyCode)
            let countryCode = String(currencyCode.prefix(2))
            let currencyName = (currencyLocale as NSLocale).displayName(forKey:NSLocale.Key.currencyCode, value: currencyCode)
            let countryName = (NSLocale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            
            Text(Currency.countryFlag(countryCode: countryCode))
                .font(.system(size: 30))
            
            VStack(alignment:.leading){
                Text("\(currencyCode)")
                Text(currencyName ?? "")
                    .font(.caption)
                Text(countryName ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    CurrencyCellView(currencyCode: "BDT")
}
