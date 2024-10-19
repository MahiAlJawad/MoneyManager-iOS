//
//  AddCurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss
    
    // TODO: Need to omit saved currencies from this list
    let localeCurrencies = Locale.commonISOCurrencyCodes

    var body: some View {
            List(localeCurrencies, id: \.self) { currencyCode in
                HStack {
                    CurrencyCellView(currencyCode: currencyCode)
                }
            }
            .applyListItemHeight()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Currencies")
    }
}

#Preview {
    AddCurrencyView()
}
