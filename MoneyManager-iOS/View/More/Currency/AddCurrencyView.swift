//
//  AddCurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MoreTabView.Router.self) private var router
    
    @State var searchText: String = ""
    @Binding var savedCurrencies: [String]
    @Binding var isSheetPresented: Bool
    
    @Binding var newCurrencies: [Contact]
    
    let localeCurrencies = Locale.commonISOCurrencyCodes
    let usedCurrencies = UserDefaults.standard.object(forKey:"SavedCurrencies") as? [String] ?? [String]()
    
    var allCurrencies: [String] {
        if searchText.isEmpty {
            var searchedCurrencies: [String] = []
            localeCurrencies.forEach { currencyCode in
                if !usedCurrencies.contains(currencyCode) {
                    searchedCurrencies.append(currencyCode)
                }
            }
            
            return searchedCurrencies
        } else {
            var searchedCurrencies: [String] = []
            localeCurrencies.forEach { currencyCode in
                if usedCurrencies.contains(currencyCode) { return }
                let currencyLocale = Locale(identifier: currencyCode)
                let countryCode = String(currencyCode.prefix(2))
                let currencyName = (currencyLocale as NSLocale).displayName(forKey:NSLocale.Key.currencyCode, value: currencyCode)
                let countryName = (NSLocale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
                
                if countryCode.localizedStandardContains(searchText) || currencyCode.localizedStandardContains(searchText){
                    searchedCurrencies.append(currencyCode)
                }
                
                if let currencyName = currencyName, currencyName.localizedStandardContains(searchText), !searchedCurrencies.contains(currencyCode) {
                    searchedCurrencies.append(currencyCode)
                }
                
                if let countryName = countryName, countryName.localizedStandardContains(searchText), !searchedCurrencies.contains(currencyCode) {
                    searchedCurrencies.append(currencyCode)
                }
            }
            return searchedCurrencies
        }
    }
    
    
    var body: some View {
        List(allCurrencies, id: \.self) { currencyCode in
            HStack {
                CurrencyCellView(currencyCode: currencyCode)
            }
            .makeFullWidthListItemTappable {
                router.navigateForSecondNavigation(to: .currencyConversionView(selectedCurrency: currencyCode))
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
        .searchable(text: $searchText)
        .textInputAutocapitalization(.never)
        .overlay(alignment: .center) {
            if !searchText.isEmpty && allCurrencies.isEmpty {
                ContentUnavailableView("Search result not found", systemImage: "magnifyingglass.circle.fill")
            }
        }
        .navigationTitle("Currencies")
    }
}
