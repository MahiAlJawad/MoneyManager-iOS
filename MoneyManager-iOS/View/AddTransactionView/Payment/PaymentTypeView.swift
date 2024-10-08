//
//  PaymentTypeView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 9/10/24.
//

import SwiftUI
import SwiftData

struct PaymentType {
    var category: Category
    
    enum Category: CaseIterable, Identifiable {
        var id : String { UUID().uuidString }
        
        case cash, creditCard, debitCard
        case banktransfer, voucher, mobilePayment
        case webPayment, other
        
        var description: String {
            switch self {
            case .cash: return "Cash"
            case .creditCard: return "Credit Card"
            case .debitCard: return "Debit Card"
            case .banktransfer: return "Bank Transfer"
            case .voucher: return "Voucher"
            case .mobilePayment: return "Mobile Payment"
            case .webPayment: return "Web Payment"
            case .other: return "Other"
            }
        }
    }
}

struct PaymentTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var payment: PaymentType
    
    var body: some View {
        NavigationStack {
            List(PaymentType.Category.allCases) { value in
                Button(value.description) {
                    payment = .init(category: value)
                    dismiss()
                }
                .padding()
                .foregroundStyle (
                    payment.category == value ? .blue : .black
                )
            }
            .navigationTitle("Payment Method")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
