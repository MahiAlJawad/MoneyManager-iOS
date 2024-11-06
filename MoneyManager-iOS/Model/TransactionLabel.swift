//
//  TransactionLabel.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/11/24.
//

import Foundation
import SwiftData

@Model
class TransactionLabel {
    var id: String
    var name: String
    var color: String
    
    init(name: String, color: String) {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
    }
}
