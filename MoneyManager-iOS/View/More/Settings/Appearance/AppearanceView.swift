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
                HStack {
                    Text("System")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
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
