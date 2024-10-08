//
//  More.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 8/10/24.
//

import Foundation

struct MoreMenuItem: Identifiable, Hashable {
    var id = UUID()
    var image: String
    var title: String
}

extension MoreMenuItem {
    // TODO: Need to take these Data from DB
    static var moreMenuItems: [MoreMenuItem] = [
        MoreMenuItem(image: "dollarsign.circle.fill", title: "Records"),
        MoreMenuItem(image: "person.text.rectangle.fill", title: "Investments"),
        MoreMenuItem(image: "suitcase.cart", title: "Wallet for your business"),
        MoreMenuItem(image: "figure.socialdance", title: "Follow us"),
        MoreMenuItem(image: "gear.badge", title: "Settings"),
        MoreMenuItem(image: "wallet.bifold", title: "About Wallet"),
        MoreMenuItem(image: "questionmark.circle", title: "Help"),
    ]
}
