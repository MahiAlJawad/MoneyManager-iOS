//
//  MoreView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 8/10/24.
//

import SwiftUI

struct MoreMenuItem: Identifiable, Hashable {
    var id = UUID()
    var image: String
    var title: String
}

let moreMenuItems = [
    MoreMenuItem(image: "dollarsign.circle.fill", title: "Records"),
    MoreMenuItem(image: "person.text.rectangle.fill", title: "Investments"),
    MoreMenuItem(image: "suitcase.cart", title: "Wallet for your business"),
    MoreMenuItem(image: "figure.socialdance", title: "Follow us"),
    MoreMenuItem(image: "gear.badge", title: "Settings"),
    MoreMenuItem(image: "wallet.bifold", title: "About Wallet"),
    MoreMenuItem(image: "questionmark.circle", title: "Help"),
]

struct MoreView: View {
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(moreMenuItems) { item in
                        NavigationLink(value: item) {
                            VStack {
                                Image(systemName: item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                
                                Text(item.title)
                                    .font(.caption)
                                    .padding()
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(minWidth: 150, maxHeight: 150, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("More")
            .navigationDestination(for: MoreMenuItem.self) { moreMenuItem in
                Text("MoreDetailsView")
            }
        }
    }
}
