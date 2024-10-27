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


class CurrencyvViewModel: ObservableObject {
    static let instance = CurrencyvViewModel()

    let exchangeRateAPI = "https://v6.exchangerate-api.com/v6/76dbedf4133b32d24c239d63/pair/"
    
    @Published var dataresponse: DataResponse?
    
    @MainActor
    func fetchedData(
        from: String,
        to: String
    ) async throws -> DataResponse {
        let urlString = exchangeRateAPI + from + "/" + to
        print("check urlString \(urlString)")
        let url = URL(string: urlString)!
        let (data, response) = try await URLSession.shared.data(from: url)
        print("response is \(response) and data is \(data)")
        let wrapper1 = try JSONDecoder().decode(DataResponse.self, from: data)
        self.dataresponse = wrapper1
        return wrapper1
    }
}
