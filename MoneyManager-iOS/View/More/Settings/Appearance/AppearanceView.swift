//
//  AppearanceView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 09/05/26.
//

import SwiftUI

struct AppearanceView: View {
    var body: some View {
        List {
            Section("Theme") {
                Text("Appearance settings will be available here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppearanceView()
    }
}
