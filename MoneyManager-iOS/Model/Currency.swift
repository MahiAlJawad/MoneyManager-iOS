//
//  Currency.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import Foundation

struct Currency: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    
    var countryName: String?
    var countryCode: String?
    var currencyCode: String?
    var currencyName: String?
    var conversionRate: Double?
    
    init(
        countryName: String? = nil,
        countryCode: String? = nil,
        currencyCode: String? = nil,
        currencyName: String? = nil,
        conversionRate: Double? = nil
    ) {
        self.countryName = countryName
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.currencyName = currencyName
        self.conversionRate = conversionRate
    }
}

extension Currency {
    static func savedCurrencyCodes(currencies: [Currency]) -> [String] {
        return currencies.map { $0.currencyCode ?? "" }
    }
    
    static func saveNewCurrency(savedCurrencies: [Currency]) {
        do {
            let encodedData = try JSONEncoder().encode(savedCurrencies)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "SavedCurrencies")
        } catch {
            print("Failed to save currency data \(error.localizedDescription)")
        }
    }
    
    static func loadData() -> [Currency] {
        var currencies: [Currency] = []
        if let savedData = UserDefaults.standard.object(forKey: "SavedCurrencies") as? Data {
            do {
                let savedCurrencyData = try JSONDecoder().decode([Currency].self, from: savedData)
                currencies = savedCurrencyData
            } catch {
                print("Failed to convert Data to Currency \(error.localizedDescription)")
            }
        }
        return currencies
    }
    
    static func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(
            countryCode.unicodeScalars.compactMap( { UnicodeScalar(127397 + $0.value) } ))
        )
    }
}

