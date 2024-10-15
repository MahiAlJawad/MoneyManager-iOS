//
//  SettingsDetails.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import SwiftUI

struct SettingsDetails: View {
    var body: some View {
        List(Settings.allSettingsData) { item in
            NavigationLink(value: MoreTabBarView.Router.Destination.particularSettingsView(settings: item)) {
                HStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.body)
                    }
                }.applyListItemHeight()
            }
        }
    }
}

#Preview {
    SettingsDetails()
}

