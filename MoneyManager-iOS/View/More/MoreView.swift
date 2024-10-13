//
//  MoreView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 8/10/24.
//

import SwiftUI

struct MoreView: View {
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(MoreMenuItem.moreMenuItems) { item in
                    switch item.title {
                    case "Settings":
                        NavigationLink(value: MoreTabBarView.Router.Destination.settingsView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Records":
                        NavigationLink(value: MoreTabBarView.Router.Destination.recordsView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Help":
                        NavigationLink(value: MoreTabBarView.Router.Destination.helpView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Investments":
                        NavigationLink(value: MoreTabBarView.Router.Destination.investmentsView) {
                            MoreCellView(item: item)
                        }
                    
                    default:
                        NavigationLink(value: MoreTabBarView.Router.Destination.aboutWalletView) {
                            MoreCellView(item: item)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("More")
    }
}

struct MoreCellView: View {
    let item: MoreMenuItem
    
    var body: some View {
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
