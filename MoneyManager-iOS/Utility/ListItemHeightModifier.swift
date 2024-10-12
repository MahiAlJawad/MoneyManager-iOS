//
//  ListItemHeightModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 12/10/24.
//

import SwiftUI

struct ListItemHeightModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 44)
    }
}
