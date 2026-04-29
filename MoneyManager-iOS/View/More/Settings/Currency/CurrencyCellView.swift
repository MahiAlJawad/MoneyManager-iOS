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
                .font(.system(size: 30))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(Currency.normalizedCurrencyCode(for: currencyCode))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(Currency.currencyName(for: currencyCode))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(Currency.countryName(for: currencyCode))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            if let trailingText {
                Text(trailingText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    CurrencyCellView(currencyCode: "BDT")
}
