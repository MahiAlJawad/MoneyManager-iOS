//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    @Binding var isAddCurrencyPresent: Bool
  //  @Binding var savedCurrencies: [String]
    @State private var savedCurrencies = UserDefaults.standard.object(forKey:"SavedCurrencies") as? [String] ?? [String]()
    
    private func delete(indexSet: IndexSet) {
        indexSet.forEach { index in
            savedCurrencies.remove(at: index)
            UserDefaults.standard.set(savedCurrencies, forKey: "SavedCurrencies")
            
        }
    }
    var body: some View {
        Form {
            Section {
                BaseCurrencyView()
                List {
                    ForEach(savedCurrencies, id: \.self) { item in
                        CurrencyCellView(currencyCode: item)
                    }.onDelete(perform: delete)
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
//        .sheet(isPresented: $isAddCurrencyPresent, content: {
//            NavigationView {
//                AddCurrencyView(savedCurrencies: $savedCurrencies)
//            }
//        })
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
