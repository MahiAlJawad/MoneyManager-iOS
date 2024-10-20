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
            if item.title == "Currency" {
                NavigationLink(value: MoreTabView.Router.Destination.currencyView) {
                    SettingsDetailsCommon(settingsItem: item)
                }
            } else {
                NavigationLink(value: MoreTabView.Router.Destination.particularSettingsView(settings: item)) {
                    SettingsDetailsCommon(settingsItem: item)
                }
            }
        }
    }
}

#Preview {
    SettingsDetails()
}

struct SettingsDetailsCommon: View {
    let settingsItem: Settings
    
    var body: some View {
        HStack {
            Circle()
                .fill(.blue)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: settingsItem.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text(settingsItem.title)
                    .font(.body)
            }
        }.applyListItemHeight()
    }
}
