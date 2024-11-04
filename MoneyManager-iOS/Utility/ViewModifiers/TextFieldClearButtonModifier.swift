//
//  TextFieldClearButtonModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 4/11/24.
//
import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            Button {
                text = ""
            } label: {
                Image(systemName: "multiply.circle.fill")
            }
            .opacity(text.isEmpty ? 0 : 1)
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(.trailing, 4)
        }
    }
}

extension TextField {
    func clearButton(on text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
    }
}
