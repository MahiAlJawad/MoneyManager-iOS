//
//  AccountSelectionView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//
import SwiftUI
import SwiftData

// TODO: Needs to complete
struct AccountSelectionView: View {
    @Environment(TransactionTabView.Router.self) private var router
    @Binding var selectedAccount: Account?
    @Query var accounts: [Account]
    
    var body: some View {
        List(accounts) { account in
            accountView(for: account)
                .fullWidthListItemTapable() {
                    selectedAccount = account
                    router.navigateBack()
                }
        }
        .navigationTitle("Select Account")
    }
    
    private func accountView(for account: Account) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(account.accountName)
                Text(account.accountBalance, format: .currency(code: "BDT"))
                Text(account.accountType.description)
                    .font(.caption)
            }
        } icon: {
            Image(systemName: account.iconName)
        }
    }
}
