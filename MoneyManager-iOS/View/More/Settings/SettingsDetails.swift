//
//  SettingsDetails.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 15/10/24.
//

import SwiftUI

struct SettingsDetails: View {
    @State private var savedCurrencies = UserDefaults.standard.object(forKey:"SavedCurrencies") as? [String] ?? [String]()
    
    var body: some View {
        List(Settings.allSettingsData) { item in
            if item.title == "Currency" {
                NavigationLink(value: MoreTabBarView.Router.Destination.currencyView(savedCurrencies: $savedCurrencies)) {
                    SettingsDetailsCommon(settingsItem: item)
                }
            } else {
                NavigationLink(value: MoreTabBarView.Router.Destination.particularSettingsView(settings: item)) {
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
