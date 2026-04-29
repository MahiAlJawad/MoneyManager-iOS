//
//  CurrencyView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 19/10/24.
//

import SwiftUI

struct CurrencyView: View {
    @Binding var isAddCurrencyPresent: Bool
    @Binding var savedCurrencies: [Currency]
    
    @State private var decimalPlaces = Currency.loadDecimalPlaces()
    @State private var isDecimalPlacesViewPresented = false
    
    private var baseCurrencyCode: String {
        Currency.baseCurrencyCode
    }
    
    private func deleteCurrency(currency: Currency) {
        guard let index = savedCurrencies.firstIndex(of: currency) else { return }
        savedCurrencies.remove(at: index)
        Currency.saveNewCurrency(savedCurrencies: savedCurrencies)
    }
    
    var body: some View {
        List {
            Section {
                BaseCurrencyCardView(currencyCode: baseCurrencyCode)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            
            Section {
                ForEach(savedCurrencies) { currency in
                    if let currencyCode = currency.currencyCode {
                        CurrencyCardRowView(currencyCode: currencyCode)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteCurrency(currency: currency)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                
            } header: {
                SectionLabelView(title: "Other Currencies")
            }
            
            Section {
                CurrencySettingsGroupView(
                    decimalPlacesLabel: decimalPlacesLabel,
                    onDecimalPrecisionTap: {
                        isDecimalPlacesViewPresented = true
                    }
                )
                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } header: {
                SectionLabelView(title: "Currency Settings", topPadding: 8)
            }
        }
        .navigationDestination(isPresented: $isDecimalPlacesViewPresented) {
            CurrencyDecimalPlacesView(decimalPlaces: $decimalPlaces)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Currencies")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            addCurrencyButton
        }
        .onAppear {
            decimalPlaces = Currency.loadDecimalPlaces()
        }
    }
    
    private var decimalPlacesLabel: String {
        decimalPlaces == 1 ? "1 place" : "\(decimalPlaces) places"
    }
    
    private var addCurrencyButton: some View {
        Button {
            isAddCurrencyPresent = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                
                Text("Add Currency")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(addCurrencyButtonForegroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(addCurrencyButtonBackgroundColor, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(addCurrencyButtonBorderColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.24 : 0.12), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var addCurrencyButtonBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "4D47D9") : Color(hex: "5B4BC4")
    }
    
    private var addCurrencyButtonForegroundColor: Color {
        .white
    }
    
    private var addCurrencyButtonBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
    }
}

private struct BaseCurrencyCardView: View {
    let currencyCode: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Currency")
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .tracking(1.1)
                .foregroundStyle(baseAccentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(baseBadgeBackgroundColor, in: Capsule())
            
            HStack(spacing: 14) {
                Text(Currency.flag(for: currencyCode))
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(Currency.normalizedCurrencyCode(for: currencyCode))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(Currency.currencyName(for: currencyCode))
                        .font(.subheadline)
                        .foregroundStyle(baseAccentColor)
                    
                    Text(Currency.countryName(for: currencyCode))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(baseCardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(baseCardBorderColor, lineWidth: 1)
        )
    }
    
    private var baseAccentColor: Color {
        colorScheme == .dark ? Color(hex: "B8B3FF") : Color(hex: "5B4BC4")
    }
    
    private var baseBadgeBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "2E2A52") : Color(hex: "E9E0FF")
    }
    
    private var baseCardBackgroundColor: Color {
        Color(uiColor: colorScheme == .dark ? .secondarySystemGroupedBackground : .secondarySystemGroupedBackground)
    }
    
    private var baseCardBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color(hex: "DFD4FF")
    }
}

private struct CurrencyCardRowView: View {
    let currencyCode: String
    
    var body: some View {
        CurrencyCellView(currencyCode: currencyCode)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SectionLabelView: View {
    let title: String
    var topPadding: CGFloat = 18
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .padding(.leading, 16)
            .padding(.top, topPadding)
    }
}

private struct CurrencySettingsGroupView: View {
    let decimalPlacesLabel: String
    let onDecimalPrecisionTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            CurrencySettingsStaticRowView(
                iconName: "arrow.triangle.2.circlepath",
                iconBackgroundColor: Color(hex: "E8F3EB"),
                iconForegroundColor: Color(hex: "2B7A4B"),
                title: "Auto-update rates",
                value: "Daily"
            )
            
            Divider()
                .padding(.leading, 60)
            
            Button(action: onDecimalPrecisionTap) {
                CurrencySettingsNavigationRowView(
                    iconName: "textformat.123",
                    iconBackgroundColor: Color(hex: "FFF1D8"),
                    iconForegroundColor: Color(hex: "A16A0A"),
                    title: "Decimal precision",
                    value: decimalPlacesLabel
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CurrencySettingsStaticRowView: View {
    let iconName: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            settingsIcon
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    private var settingsIcon: some View {
        Image(systemName: iconName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(iconForegroundColor)
            .frame(width: 32, height: 32)
            .background(iconBackgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct CurrencySettingsNavigationRowView: View {
    let iconName: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(iconForegroundColor)
                .frame(width: 32, height: 32)
                .background(iconBackgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

private struct CurrencyDecimalPlacesView: View {
    @Binding var decimalPlaces: Int
    
    var body: some View {
        List {
            Section {
                ForEach(Currency.supportedDecimalPlaces, id: \.self) { option in
                    Button {
                        decimalPlaces = option
                        Currency.saveDecimalPlaces(option)
                    } label: {
                        HStack {
                            Text(option == 1 ? "1 decimal place" : "\(option) decimal places")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if decimalPlaces == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "3D6B31"))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text("This precision is used when showing exchange rates in currency details.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Decimal Precision")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview("CurrencyView") {
    // Sample preview data for saved currencies
    struct PreviewContainer: View {
        @State private var isAddCurrencyPresent: Bool = false
        @State private var savedCurrencies: [Currency] = [
            Currency(currencyCode: "USD"),
            Currency(currencyCode: "EUR"),
            Currency(currencyCode: "JPY")
        ]
        
        var body: some View {
            NavigationStack {
                CurrencyView(
                    isAddCurrencyPresent: $isAddCurrencyPresent,
                    savedCurrencies: $savedCurrencies
                )
            }
        }
    }
    
    return PreviewContainer()
}
