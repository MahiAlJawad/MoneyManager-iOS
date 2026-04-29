//
//  CurrencyCellView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyCellView: View {
    let currencyCode: String
    var trailingText: String? = nil
    var showsChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(Currency.flag(for: currencyCode))
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(Currency.normalizedCurrencyCode(for: currencyCode))
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(Currency.currencyName(for: currencyCode))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(Currency.countryName(for: currencyCode))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            if let trailingText {
                Text(trailingText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(minHeight: 60)
    }
}

#Preview {
    CurrencyCellView(currencyCode: "BDT")
}
