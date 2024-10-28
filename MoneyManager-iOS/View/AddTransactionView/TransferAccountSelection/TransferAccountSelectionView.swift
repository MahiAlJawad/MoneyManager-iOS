//
//  TransferAccountSelectionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 27/10/24.
//

import SwiftData
import SwiftUI

struct TransferAccountSelectionView: View {
    @Environment(TransactionTabView.Router.self) private var router
    
    private let account: Account?
    @Binding private var transferAccount: Account?
    
    @Query(sort: [.init(\Account.name)])
    private var accounts: [Account]
    
    init(from account: Account?, transferAccount: Binding<Account?>) {
        self.account = account
        _transferAccount = transferAccount
        guard let accountID = account?.id else { return }
        _accounts = Query(
            filter: #Predicate<Account> { $0.id != accountID },
            sort: [.init(\.name)]
        )
    }
    
    var body: some View {
        List(accounts) { account in
            accountView(for: account)
                .makeFullWidthListItemTappable() {
                    transferAccount = account
                    router.navigateBack()
                }
        }
        .navigationTitle("Select Transfer Account")
    }
    
    private func accountView(for account: Account) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(account.name)
                Text(account.accountBalance, format: .currency(code: "BDT"))
                Text(account.accountType.description)
                    .font(.caption)
            }
        } icon: {
            Image(systemName: account.iconName)
        }
    }
}
