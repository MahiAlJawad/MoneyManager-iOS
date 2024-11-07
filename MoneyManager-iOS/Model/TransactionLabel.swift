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

extension TransactionLabel {
    static func addLabel(in modelContext: ModelContext, with labelInfo: AddLabelView.LabelInfo) {
        let label = TransactionLabel(name: labelInfo.name, color: labelInfo.color.hexString)
        modelContext.insert(label)
    }
    
    func deleteLabel(from modelContext: ModelContext) {
        modelContext.delete(self)
    }
}
