//
//  ListItemHeightModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 12/10/24.
//

import SwiftUI

struct ListItemHeightModifier: ViewModifier {
    fileprivate init() { }
    
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 44)
    }
}

extension View {
    public func applyListItemHeight() -> some View {
        modifier(ListItemHeightModifier())
    }
}
