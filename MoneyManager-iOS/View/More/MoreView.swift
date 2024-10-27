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
                        NavigationLink(value: MoreTabView.Router.Destination.settingsView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Records":
                        NavigationLink(value: MoreTabView.Router.Destination.recordsView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Help":
                        NavigationLink(value: MoreTabView.Router.Destination.helpView) {
                            MoreCellView(item: item)
                        }
                        
                    case "Investments":
                        NavigationLink(value: MoreTabView.Router.Destination.investmentsView) {
                            MoreCellView(item: item)
                        }
                    
                    default:
                        NavigationLink(value: MoreTabView.Router.Destination.aboutWalletView) {
                            MoreCellView(item: item)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                .frame(width: 40, height: 40)
            Text(item.title)
                .foregroundStyle(Color(uiColor: .label))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150)
        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}
