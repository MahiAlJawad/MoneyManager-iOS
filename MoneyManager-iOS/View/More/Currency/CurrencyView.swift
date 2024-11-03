//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    @Binding var isAddCurrencyPresent: Bool
    @Binding var savedCurrencies: [String]
    @Binding var contacts: [Contact]
    
    private func delete(indexSet: IndexSet) {
        indexSet.forEach { index in
            savedCurrencies.remove(at: index)
            UserDefaults.standard.set(savedCurrencies, forKey: "SavedCurrencies")
        }
    }
    
    private func deleteNewCurrency(indexSet: IndexSet) {
        indexSet.forEach { index in
            contacts.remove(at: index)
            do {
                let encodedData = try JSONEncoder().encode(contacts)
                let userDefaults = UserDefaults.standard
                userDefaults.set(encodedData, forKey: "contacts")
            } catch {
                // Failed to encode Contact to Data
            }
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
                List {
                    ForEach(contacts, id: \.self) { contact in
                        Text(contact.name)
                    }.onDelete(perform: deleteNewCurrency)
                }
               
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
