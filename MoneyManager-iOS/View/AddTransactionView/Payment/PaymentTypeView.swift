//
//  PaymentTypeView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 9/10/24.
//

import SwiftUI
import SwiftData

struct PaymentTypeView: View {
    typealias PaymentMethod = Transaction.PaymentMethod
    
    @Environment(\.dismiss) private var dismiss
    @Binding var paymentMethod: PaymentMethod
    
    var body: some View {
        List {
            ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                Button(paymentMethod.description) {
                    self.paymentMethod = paymentMethod
                    dismiss()
                }
                .padding()
                .foregroundStyle (
                    self.paymentMethod == paymentMethod ? .blue : .black
                )
            }
        }
        .navigationTitle("Payment Method")
        .navigationBarTitleDisplayMode(.inline)
    }
}
