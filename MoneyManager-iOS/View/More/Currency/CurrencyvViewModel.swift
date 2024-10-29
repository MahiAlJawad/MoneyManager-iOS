//
//  CurrencyModel.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 27/10/24.
//

import Foundation

struct DataResponse: Codable {
    let base_code: String
    let target_code: String
    let conversion_rate: Double
}

// MARK: LoadingState
enum LoadingState<Data> {
    case loaded(Data)
    case loading
    case failed(ResponseError)
}

// MARK: Errors
enum ResponseError: Error {
    case urlConvertionError
    case error(String)
}


@Observable
final class CurrencyModel {
    private var currenyConversionAPIManager = CurrencyConversionAPIManager.instance
    private(set) var dataresponse: LoadingState<DataResponse> = .loading
    
    var fromCurrency: String = ""
    var toCurrency: String = ""
    
    @MainActor
    func loadData() async {
        let result = await currenyConversionAPIManager.fetchedData(from: fromCurrency, to: toCurrency)
        
        print("from \(fromCurrency) and to \(toCurrency) and result is \(result)")
        switch result {
        case .success(let response):
            dataresponse = .loaded(response)
        case .failure(let error):
            dataresponse = .failed(error)
        }
        
    }
}
