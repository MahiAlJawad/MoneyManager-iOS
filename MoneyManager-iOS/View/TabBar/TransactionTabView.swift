//
//  TransactionTabView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 10/10/24.
//

import SwiftUI

struct TransactionTabView: View {
    @State var router = Router()
    private let initialTransactionType: Transaction.TransactionType
    private let initialAccount: Account?
    private let editingTransaction: Transaction?
    
    init(
        initialTransactionType: Transaction.TransactionType = .expense,
        initialAccount: Account? = nil,
        editingTransaction: Transaction? = nil
    ) {
        self.initialTransactionType = initialTransactionType
        self.initialAccount = initialAccount
        self.editingTransaction = editingTransaction
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            AddTransactionView(
                initialTransactionType: initialTransactionType,
                initialAccount: initialAccount,
                editingTransaction: editingTransaction
            )
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .accountSelectionView(let account, let transferAccount):
                        AccountSelectionView(from: account, transferAccount: transferAccount)
                    case .categorySelectionView(let category):
                        CategorySelectionView(selectedCategory: category)
                    case let .transferAccountSelectionView(account, transferAccount):
                        TransferAccountSelectionView(from: account, transferAccount: transferAccount)
                    case .categoryDetailsView(let category,let selectedCategory):
                        CategoryDetailsView(category: category, selectedCategory: selectedCategory)
                    case .currencySelectionView(let selectedCurrency):
                        CurrencySelectionView(selectedCurrency: selectedCurrency)
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
            case accountSelectionView(account: Binding<Account?>, transferAccount: Account?)
            case categorySelectionView(category: Binding<Category?>)
            case transferAccountSelectionView(account: Account?, transferAccount: Binding<Account?>)
            case categoryDetailsView(category: Transaction.MainCategory, selectedCategory: Binding<Category?>)
            case currencySelectionView(selectedCurrency: Binding<Currency>)
            
            static func ==(lhs: Destination, rhs: Destination) -> Bool {
                switch (lhs, rhs) {
                case (.accountSelectionView, .accountSelectionView):
                    return true
                case (.categorySelectionView, .categorySelectionView):
                    return true
                case (.transferAccountSelectionView, .transferAccountSelectionView):
                    return true
                case (.categoryDetailsView, .categoryDetailsView):
                    return true
                case (.currencySelectionView, .currencySelectionView):
                    return true
                default: return false
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .accountSelectionView:
                    hasher.combine("account")
                case .transferAccountSelectionView:
                    hasher.combine("transferAccount")
                case .categorySelectionView:
                    hasher.combine("category")
                case .categoryDetailsView:
                    hasher.combine("categoryDetailsView")
                case .currencySelectionView:
                    hasher.combine("currencySelectionView")
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
