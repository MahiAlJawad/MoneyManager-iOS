//
//  CurrencyvViewModel.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 27/10/24.
//

import Foundation

struct DataResponse: Codable {
    let time_next_update_utc: String
    let base_code: String
    let target_code: String
    let conversion_rate: Double
}

@Observable
class CurrencyvViewModel {
    static let instance = CurrencyvViewModel()
    
    let exchangeRateAPI = "https://v6.exchangerate-api.com/v6/76dbedf4133b32d24c239d63/pair/"
    
    var dataresponse: DataResponse?
    
    @MainActor
    func fetchedData(
        from: String,
        to: String
    ) async throws -> DataResponse {
        let urlString = exchangeRateAPI + from + "/" + to
        
        let url = URL(string: urlString)!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let dataResponse = try JSONDecoder().decode(DataResponse.self, from: data)
        self.dataresponse = dataResponse
        return dataResponse
    }
}
