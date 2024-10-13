//
//  FullWidthListItemTapableModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 12/10/24.
//

import SwiftUI

struct FullWidthListItemTapableModifier: ViewModifier {
    enum Alignment {
        case left
        case right
        case center
    }
    
    var alignment: Alignment
    var onTapAction: (() -> Void)?
    
    init(alignment: Alignment = .left, onTapAction: (() -> Void)? = nil) {
        self.alignment = alignment
        self.onTapAction = onTapAction
    }
    
    func body(content: Content) -> some View {
        HStack {
            if alignment == .right || alignment == .center {
                Spacer()
            }
            content
            if alignment == .left || alignment == .center {
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTapAction?()
        }
    }
}

extension View {
    func fullWidthListItemTapable(
        alignment: FullWidthListItemTapableModifier.Alignment = .left,
        onTapAction: (() -> Void)? = nil
    ) -> some View {
        modifier(FullWidthListItemTapableModifier(alignment: alignment, onTapAction: onTapAction))
    }
}
