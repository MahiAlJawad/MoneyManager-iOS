//
//  AmountKeyboardView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 19/4/26.
//

import SwiftUI

struct AmountKeyboardView: View {
    let onKeyTap: (AmountKeyboardKey) -> Void
    
    private let rows: [[AmountKeyboardKey]] = [
        [.clear, .backspace, .divide, .multiply],
        [.digit("7"), .digit("8"), .digit("9"), .subtract],
        [.digit("4"), .digit("5"), .digit("6"), .add],
        [.digit("1"), .digit("2"), .digit("3"), .equals],
        [.decimal, .digit("0"), .percent, .done]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row) { key in
                        button(for: key)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.regularMaterial)
    }
    
    private func button(for key: AmountKeyboardKey) -> some View {
        Button {
            onKeyTap(key)
        } label: {
            Text(key.title)
                .font(.title3.weight(key.isPrimaryAction ? .semibold : .medium))
                .foregroundStyle(key.foregroundColor)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(key.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

enum AmountKeyboardKey: Identifiable, Hashable {
    case digit(String)
    case decimal
    case add
    case subtract
    case multiply
    case divide
    case clear
    case backspace
    case percent
    case equals
    case done
    
    var id: String {
        title
    }
    
    var title: String {
        switch self {
        case .digit(let digit): return digit
        case .decimal:          return "."
        case .add:              return "+"
        case .subtract:         return "-"
        case .multiply:         return "*"
        case .divide:           return "/"
        case .clear:            return "C"
        case .backspace:        return "⌫"
        case .percent:          return "%"
        case .equals:           return "="
        case .done:             return "Done"
        }
    }
    
    var operatorSymbol: String? {
        switch self {
        case .add, .subtract, .multiply, .divide:
            title
        default:
            nil
        }
    }
    
    fileprivate var isPrimaryAction: Bool {
        self == .done
    }
    
    fileprivate var backgroundColor: Color {
        switch self {
        case .done:
            Color.red
        case .clear, .backspace:
            Color(uiColor: .secondarySystemFill)
        case .add, .subtract, .multiply, .divide:
            Color(uiColor: .tertiarySystemFill)
        case .digit, .decimal, .percent, .equals:
            Color(uiColor: .secondarySystemGroupedBackground)
        }
    }
    
    fileprivate var foregroundColor: Color {
        switch self {
        case .done:
            .white
        default:
            .primary
        }
    }
}
