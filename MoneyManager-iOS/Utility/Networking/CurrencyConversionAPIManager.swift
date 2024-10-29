//
//  CurrencyConversionAPIManager.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 28/10/24.
//

import Foundation

class CurrencyConversionAPIManager {
    static let instance = CurrencyConversionAPIManager()
    
    private let exchangeRateAPI = "https://v6.exchangerate-api.com/v6/76dbedf4133b32d24c239d63/pair/"
    
    @MainActor
    func fetchedData(
        from: String,
        to: String
    ) async -> Result<DataResponse, ResponseError> {
        let urlString = exchangeRateAPI + from + "/" + to
        
        guard let url = URL(string: urlString) else {
            return .failure(.urlConvertionError)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let dataResponse = try JSONDecoder().decode(DataResponse.self, from: data)
            return .success(dataResponse)
        } catch {
            print("Error while getting data \(error)")
            return .failure(.error(error.localizedDescription))
        }
    }
}
