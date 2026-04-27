//
//  CurrencyDetailsView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 24/10/24.
//

import SwiftUI

struct CurrencyDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    let currentCurrencies: [String]
    let decimalPlaces: Int
    var onSaveCompletion: (() -> Void)? = nil
    
    @State private var currencyViewModel = CurrencyModel()
    @State private var selectedDirection: ConversionDirection = .baseToTarget
    @State private var editedRateText = ""
    @State private var draftBaseRate: Double?
    @State private var seededInitialRate = false
    @State private var shouldIgnoreNextEditedRateTextChange = false
    
    @Binding var savedNewCurrencies: [Currency]
    
    private var baseCurrency: String { currentCurrencies[0] }
    private var targetCurrency: String { currentCurrencies[1] }
    
    private var selectedSourceCurrency: String {
        selectedDirection == .baseToTarget ? baseCurrency : targetCurrency
    }
    
    private var selectedDestinationCurrency: String {
        selectedDirection == .baseToTarget ? targetCurrency : baseCurrency
    }
    
    private var currentSavedBaseRate: Double? {
        savedNewCurrencies.first(where: { $0.currencyCode == targetCurrency })?.conversionRate
    }
    
    private var savedRateCardTitle: String {
        currentSavedBaseRate == nil ? "CURRENT RATE" : "CURRENTLY SAVED RATE"
    }
    
    private var fetchedBaseRate: Double? {
        guard case .loaded(let data) = currencyViewModel.dataResponse else {
            return nil
        }
        return data.conversion_rate
    }
    
    private var initialBaseRate: Double {
        currentSavedBaseRate ?? fetchedBaseRate ?? 1
    }
    
    private var displayedSavedRate: Double {
        rateForSelectedDirection(fromBaseRate: initialBaseRate)
    }
    
    private var editedRateValue: Double? {
        Double(editedRateText)
    }
    
    private var currentDraftBaseRate: Double {
        draftBaseRate ?? initialBaseRate
    }
    
    private var displayedDraftRate: Double {
        rateForSelectedDirection(fromBaseRate: currentDraftBaseRate)
    }
    
    private var effectiveEditedRate: Double {
        editedRateValue ?? displayedDraftRate
    }
    
    private var baseRateToSave: Double {
        switch selectedDirection {
        case .baseToTarget:
            return max(effectiveEditedRate, 0)
        case .targetToBase:
            guard effectiveEditedRate > 0 else { return initialBaseRate }
            return 1 / effectiveEditedRate
        }
    }
    
    private var isSaveEnabled: Bool {
        guard let editedRateValue else { return false }
        return editedRateValue > 0
    }
    
    private func rateForSelectedDirection(fromBaseRate baseRate: Double) -> Double {
        switch selectedDirection {
        case .baseToTarget:
            return baseRate
        case .targetToBase:
            guard baseRate != 0 else { return 0 }
            return 1 / baseRate
        }
    }
    
    private func seedEditedRateIfNeeded() {
        guard !seededInitialRate else { return }
        draftBaseRate = initialBaseRate
        setEditedRateText(displayedDraftRate)
        seededInitialRate = true
    }
    
    private func syncEditedRateForDirection() {
        setEditedRateText(displayedDraftRate)
    }
    
    private func updateDraftRate() {
        guard let editedRateValue, editedRateValue > 0 else { return }
        
        switch selectedDirection {
        case .baseToTarget:
            draftBaseRate = editedRateValue
        case .targetToBase:
            draftBaseRate = 1 / editedRateValue
        }
    }
    
    private func setEditedRateText(_ rate: Double) {
        shouldIgnoreNextEditedRateTextChange = true
        editedRateText = formattedNumber(rate, minFraction: 0, maxFraction: decimalPlaces)
    }
    
    private func saveRate() {
        let savedCurrency = Currency(
            currencyCode: targetCurrency,
            conversionRate: baseRateToSave
        )
        
        if let existingIndex = savedNewCurrencies.firstIndex(where: { $0.currencyCode == targetCurrency }) {
            savedNewCurrencies[existingIndex] = savedCurrency
        } else {
            savedNewCurrencies.append(savedCurrency)
        }
        
        Currency.saveNewCurrency(savedCurrencies: savedNewCurrencies)
        dismiss()
        onSaveCompletion?()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            switch currencyViewModel.dataResponse {
            case .loaded:
                rateEditorContent
                ManualRateKeypad(
                    displayedNumber: $editedRateText,
                    decimalPlaces: decimalPlaces,
                    saveAction: saveRate,
                    isSaveEnabled: isSaveEnabled
                )
                .onAppear {
                    seedEditedRateIfNeeded()
                }
            case .loading:
                Spacer()
                ProgressView()
                Spacer()
            case .failed:
                rateEditorContent
                ManualRateKeypad(
                    displayedNumber: $editedRateText,
                    decimalPlaces: decimalPlaces,
                    saveAction: saveRate,
                    isSaveEnabled: isSaveEnabled
                )
                .onAppear {
                    seedEditedRateIfNeeded()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .navigationTitle("Set exchange rate")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color(hex: "F7F6FB").ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: "F2F2F7"), in: Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "E1E1E8"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .task {
            currencyViewModel.fromCurrency = baseCurrency
            currencyViewModel.toCurrency = targetCurrency
            await currencyViewModel.loadData()
            seedEditedRateIfNeeded()
        }
        .onChange(of: editedRateText) {
            if shouldIgnoreNextEditedRateTextChange {
                shouldIgnoreNextEditedRateTextChange = false
                return
            }
            updateDraftRate()
        }
    }
    
    private var rateEditorContent: some View {
        VStack(spacing: 14) {
            directionPicker
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                savedRateCard
                editableRateCard
            }
            .padding(16)
            .background(Color(hex: "EFEFF3"))
        }
    }
    
    private var directionPicker: some View {
        HStack(spacing: 0) {
            directionTab(
                title: "1 \(baseCurrency) =",
                isSelected: selectedDirection == .baseToTarget
            ) {
                selectedDirection = .baseToTarget
                syncEditedRateForDirection()
            }
            
            directionTab(
                title: "1 \(targetCurrency) =",
                isSelected: selectedDirection == .targetToBase
            ) {
                selectedDirection = .targetToBase
                syncEditedRateForDirection()
            }
        }
        .padding(4)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "DEDEE8"), lineWidth: 1)
        )
    }
    
    private var savedRateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(savedRateCardTitle)
                .font(.system(size: 13, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(Color(hex: "8A8A96"))
            
            HStack(alignment: .center, spacing: 12) {
                Text("1 \(selectedSourceCurrency) = \(formattedNumber(displayedSavedRate, minFraction: 0, maxFraction: decimalPlaces)) \(selectedDestinationCurrency)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "DEDEE8"), lineWidth: 1)
        )
    }
    
    private var editableRateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1 \(selectedSourceCurrency) EQUALS")
                .font(.system(size: 14, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color(hex: "4D47D9"))
            
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(selectedDestinationCurrency)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(hex: "7A7A88"))
                
                Text(editedRateText.isEmpty ? "0" : editedRateText)
                    .font(.system(size: 52, weight: .regular))
                    .foregroundStyle(Color(hex: "B9BBC5"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                
                Rectangle()
                    .fill(Color(hex: "7A6DFF"))
                    .frame(width: 2, height: 50)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "5B4BC4"), lineWidth: 2)
        )
    }
    
    private func directionTab(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color(hex: "8A8A96"))
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(hex: "5B4BC4") : .clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func formattedNumber(_ value: Double, minFraction: Int, maxFraction: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minFraction
        formatter.maximumFractionDigits = maxFraction
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

private enum ConversionDirection {
    case baseToTarget
    case targetToBase
}

struct ManualRateKeypad: View {
    @Binding var displayedNumber: String
    let decimalPlaces: Int
    let saveAction: () -> Void
    let isSaveEnabled: Bool
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                ForEach(0..<buttons.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(buttons[rowIndex], id: \.self) { number in
                            KeypadButton(label: number) {
                                appendCharacter(number)
                            }
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    KeypadButton(label: ".") {
                        appendDecimalPoint()
                    }
                    .opacity(decimalPlaces == 0 ? 0.35 : 1)
                    .disabled(decimalPlaces == 0)
                    
                    KeypadButton(label: "0") {
                        appendCharacter("0")
                    }
                    DeleteKeypadButton {
                        deleteLastCharacter()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color(hex: "D9D9E2"))
                    .frame(height: 0.5)
            }
            
            Button(action: saveAction) {
                Text("Save rate")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .foregroundStyle(.white)
                    .background(
                        (isSaveEnabled ? Color(hex: "5B4BC4") : Color(hex: "C5C5CD")),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isSaveEnabled)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func appendCharacter(_ character: String) {
        if let decimalIndex = displayedNumber.firstIndex(of: ".") {
            let digitsAfterDecimal = displayedNumber.distance(from: displayedNumber.index(after: decimalIndex), to: displayedNumber.endIndex)
            if digitsAfterDecimal >= decimalPlaces {
                return
            }
        }
        
        if displayedNumber == "0" {
            displayedNumber = character
        } else {
            displayedNumber += character
        }
    }
    
    private func appendDecimalPoint() {
        guard decimalPlaces > 0 else { return }
        
        if displayedNumber.isEmpty {
            displayedNumber = "0."
            return
        }
        
        if !displayedNumber.contains(".") {
            displayedNumber += "."
        }
    }
    
    private func deleteLastCharacter() {
        guard !displayedNumber.isEmpty else { return }
        displayedNumber.removeLast()
    }
}

struct KeypadButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 62)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(hex: "D9D9E2"))
                .frame(height: 0.5)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(hex: "D9D9E2"))
                .frame(width: 0.5)
        }
    }
}

struct DeleteKeypadButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 62)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(hex: "D9D9E2"))
                .frame(height: 0.5)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(hex: "D9D9E2"))
                .frame(width: 0.5)
        }
    }
}

#Preview {
    @Previewable @State var previewCurrencies: [Currency] = [
        Currency(currencyCode: "USD", conversionRate: 0.0081)
    ]
    
    NavigationStack {
        CurrencyDetailsView(
            currentCurrencies: ["BDT", "USD"],
            decimalPlaces: 4,
            savedNewCurrencies: $previewCurrencies
        )
    }
}
