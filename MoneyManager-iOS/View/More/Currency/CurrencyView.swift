//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    @State var isAddCurrencyPresent: Bool = false
    
    var body: some View {
        Form {
            Section {
                BaseCurrencyView()
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
        .sheet(isPresented: $isAddCurrencyPresent, content: {
            NavigationView {
                AddCurrencyView()
            }
        })
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

#Preview {
    CurrencyView()
}
