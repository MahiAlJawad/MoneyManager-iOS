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
            Text("MoreDetailsView") //TODO: View will be updated later
        }
    }
}
