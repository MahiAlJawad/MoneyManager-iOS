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
    static let baseCurrencyCode = Locale.current.currency?.identifier ?? ""
    static let defaultDecimalPlaces = 2
    static let supportedDecimalPlaces = Array(0...6)
    
    private enum UserDefaultsKey {
        static let savedCurrencies = "SavedCurrencies"
        static let decimalPlaces = "CurrencyDecimalPlaces"
    }
    
    static var baseCurrency: Currency {
        .init(
            currencyCode: baseCurrencyCode,
            conversionRate: 1.0
        )
    }
    
    static func savedCurrencyCodes(currencies: [Currency]) -> [String] {
        return currencies.map { $0.currencyCode ?? "" }
    }
    
    static func saveNewCurrency(savedCurrencies: [Currency]) {
        do {
            let encodedData = try JSONEncoder().encode(savedCurrencies)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: UserDefaultsKey.savedCurrencies)
        } catch {
            print("Failed to save currency data \(error.localizedDescription)")
        }
    }
    
    static func loadCurrencyData() -> [Currency] {
        var currencies: [Currency] = []
        if let savedData = UserDefaults.standard.object(forKey: UserDefaultsKey.savedCurrencies) as? Data {
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
    
    static func normalizedCurrencyCode(for currencyCode: String) -> String {
        currencyCode.uppercased()
    }
    
    static func countryCode(for currencyCode: String) -> String {
        String(normalizedCurrencyCode(for: currencyCode).prefix(2))
    }
    
    static func currencyName(for currencyCode: String) -> String {
        let normalizedCurrencyCode = normalizedCurrencyCode(for: currencyCode)
        return Locale.current.localizedString(forCurrencyCode: normalizedCurrencyCode) ?? normalizedCurrencyCode
    }
    
    static func countryName(for currencyCode: String) -> String {
        let countryCode = countryCode(for: currencyCode)
        return Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
    }
    
    static func flag(for currencyCode: String) -> String {
        countryFlag(countryCode: countryCode(for: currencyCode))
    }
    
    static func loadDecimalPlaces() -> Int {
        let storedValue = UserDefaults.standard.integer(forKey: UserDefaultsKey.decimalPlaces)
        return supportedDecimalPlaces.contains(storedValue) ? storedValue : defaultDecimalPlaces
    }
    
    static func saveDecimalPlaces(_ decimalPlaces: Int) {
        let normalizedValue = supportedDecimalPlaces.contains(decimalPlaces) ? decimalPlaces : defaultDecimalPlaces
        UserDefaults.standard.set(normalizedValue, forKey: UserDefaultsKey.decimalPlaces)
    }
    
    var displayCurrencyCode: String {
        Self.normalizedCurrencyCode(for: currencyCode ?? "")
    }
    
    var displayCountryCode: String {
        Self.countryCode(for: currencyCode ?? "")
    }
    
    var displayCurrencyName: String {
        Self.currencyName(for: currencyCode ?? "")
    }
    
    var displayCountryName: String {
        Self.countryName(for: currencyCode ?? "")
    }
    
    var displayFlag: String {
        Self.flag(for: currencyCode ?? "")
    }
}
