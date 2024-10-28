//
//  DisclosureViewModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 28/10/24.
//

import SwiftUI

// TODO: The disclosure sign font size need to specify later after fixing UX
struct DisclosureIndicatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Image(systemName: "chevron.forward")
                .font(Font.system(.caption).weight(.bold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .contentShape(Rectangle())
    }
}

extension View {
    func disclosureIndicator() -> some View {
        modifier(DisclosureIndicatorModifier())
    }
}
