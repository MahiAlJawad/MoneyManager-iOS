//
//  TransactionTabView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 10/10/24.
//

import SwiftUI

struct TransactionTabView: View {
    @State var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            AddTransactionView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .accountSelectionView(let account):
                        AccountSelectionView(selectedAccount: account)
                    case .categorySelectionView(let category):
                        CategorySelectionView(selectedCategory: category)
                    case .labelSelectionView:
                        LabelSelectionView()
                    case .addNoteView(let note):
                        AddNoteView(notes: note)
                    case .selectPaymentMethodView(let paymentMethod):
                        PaymentTypeView(paymentMethod: paymentMethod)
                    }
                }
        }
        .environment(router)
    }
}

extension TransactionTabView {
    @Observable
    final class Router {
        enum Destination: Hashable {
            case accountSelectionView(account: Binding<Account?>)
            case categorySelectionView(category: Binding<Category?>)
            case labelSelectionView
            case addNoteView(note: Binding<String>)
            case selectPaymentMethodView(paymentMethod: Binding<Transaction.PaymentMethod>)
            
            static func ==(lhs: Destination, rhs: Destination) -> Bool {
                switch (lhs, rhs) {
                case let (.accountSelectionView(lhsAccount), .accountSelectionView(rhsAccount)):
                    return lhsAccount.wrappedValue == rhsAccount.wrappedValue
                case let (.categorySelectionView(lhsCategory), .categorySelectionView(rhsCategory)):
                    return lhsCategory.wrappedValue == rhsCategory.wrappedValue
                case (.labelSelectionView, .labelSelectionView):
                    return true
                case let (.addNoteView(lhsNote), .addNoteView(rhsNote)):
                    return lhsNote.wrappedValue == rhsNote.wrappedValue
                case let (.selectPaymentMethodView(lhsPaymentMethod), .selectPaymentMethodView(rhsPaymentMethod)):
                    return lhsPaymentMethod.wrappedValue == rhsPaymentMethod.wrappedValue
                default: return false
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .accountSelectionView(let account):
                    hasher.combine(account.wrappedValue?.id)
                case .categorySelectionView(let category):
                    hasher.combine(category.wrappedValue?.id)
                case .labelSelectionView:
                    hasher.combine(self)
                case .addNoteView(let note):
                    hasher.combine(note.wrappedValue) // Note should have some ID
                case .selectPaymentMethodView(let paymentMethod):
                    hasher.combine(paymentMethod.wrappedValue.description)
                }
            }
        }
        
        var path = NavigationPath()
        
        func navigate(to destination: Destination) {
            path.append(destination)
        }
        
        func navigateBack() {
            path.removeLast()
        }
        
        func navigateToRoot() {
            path.removeLast(path.count)
        }
    }
}

#Preview {
    TransactionTabView()
}
