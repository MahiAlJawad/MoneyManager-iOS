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
    static func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(
            countryCode.unicodeScalars.compactMap( { UnicodeScalar(127397 + $0.value) } ))
        )
    }
}

