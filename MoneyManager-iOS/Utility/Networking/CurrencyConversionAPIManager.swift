//
//  CurrencyConversionAPIManager.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 28/10/24.
//

import Foundation

class CurrencyConversionAPIManager {
    static let instance = CurrencyConversionAPIManager()
   // var dataresponse: LoadingState<DataResponse> = .loading
    var dataresponse: DataResponse = .init(base_code: "", target_code: "", conversion_rate: 0)
   
    let exchangeRateAPI = "https://v6.exchangerate-api.com/v6/76dbedf4133b32d24c239d63/pair/"
    
    @MainActor
    func fetchedData(
        from: String,
        to: String
    ) async -> Result<DataResponse, ResponseError> {
        let urlString = exchangeRateAPI + from + "/" + to
        
        let url = URL(string: urlString)!
        do {
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let dataResponse = try JSONDecoder().decode(DataResponse.self, from: data)
            self.dataresponse = dataResponse
            //if let dataresponse = dataResponse {
                
            return .success(.init(base_code: dataResponse.base_code, target_code: dataResponse.target_code, conversion_rate: dataResponse.conversion_rate))
            //}
        } catch {
            print("Error while getting data \(error)")
            return .failure(.error(error.localizedDescription))
        }
    }
}
