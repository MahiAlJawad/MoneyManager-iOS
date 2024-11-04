//
//  MoreTabView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 13/10/24.
//

import SwiftUI

struct MoreTabView: View {
    @State var router = Router()
    @State var addCurrencyPresent: Bool = false
    @State var savedCurrencies: [Currency] = []
    
    var body: some View {
        NavigationStack(path: $router.firstNavigationPath) {
            MoreView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .settingsView:
                        SettingsDetails()
                    case .aboutWalletView:
                        AboutWalletView()
                    case .recordsView:
                        RecordsView()
                    case .investmentsView:
                        InvestmentView()
                    case .helpView:
                        HelpView()
                    case .particularSettingsView(let settings):
                        ParticularSettingsDetails(settings: settings)
                    case .currencyView:
                        CurrencyView(
                            isAddCurrencyPresent: $addCurrencyPresent,
                            savedCurrencies: $savedCurrencies
                        ).onAppear {
                            savedCurrencies = Currency.loadCurrencyData()
                        }
                        .sheet(isPresented: $addCurrencyPresent) {
                            NavigationStack(path: $router.secondNavigationPath) {
                                AddCurrencyView(
                                    isSheetPresented: $addCurrencyPresent,
                                    newCurrencies: $savedCurrencies
                                )
                                .navigationDestination(for: Router.Destination2.self) { destination2 in
                                    switch destination2 {
                                    case .currencyConversionView(let selectedCurrency):
                                        let baseCurrencyCode = Currency.baseCurrencyCode

                                        CurrencyDetailsView(
                                            currentCurrencies: [baseCurrencyCode, selectedCurrency],
                                            savedNewCurrencies: $savedCurrencies,
                                            isSheetPresented: $addCurrencyPresent
                                        )
                                    }
                                }
                            }
                            .environment(router)
                        }
                    }
                }
        }
        .environment(router)
    }
}

extension MoreTabView {
    @Observable
    final class Router {
        public enum Destination: Hashable {
            case settingsView
            case aboutWalletView
            case recordsView
            case investmentsView
            case helpView
            case particularSettingsView(settings: Settings)
            case currencyView
            
            static func ==(lhs: Destination, rhs: Destination) -> Bool {
                switch (lhs, rhs) {
                case (.settingsView, .settingsView):
                    return true
                case (.aboutWalletView, .aboutWalletView):
                    return true
                case (.recordsView, .recordsView):
                    return true
                case (.investmentsView, .investmentsView):
                    return true
                case (.helpView, .helpView):
                    return true
                case (.particularSettingsView, .particularSettingsView):
                    return true
                case (.currencyView, .currencyView):
                    return true
                default: return false
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .settingsView:
                    hasher.combine("settingsView")
                case .aboutWalletView:
                    hasher.combine("aboutWalletView")
                case .recordsView:
                    hasher.combine("recordsView")
                case .investmentsView:
                    hasher.combine("investmentsView")
                case .helpView:
                    hasher.combine("helpView")
                case .particularSettingsView:
                    hasher.combine("individualSettingsView")
                case .currencyView:
                    hasher.combine("currenceyView")
                }
            }
        }
        
        var firstNavigationPath = NavigationPath()
        var secondNavigationPath = NavigationPath()
        
        public enum Destination2: Hashable {
            case currencyConversionView(selectedCurrency: String)
        }
        
        func navigateForSecondNavigation(to destination: Destination2) {
            secondNavigationPath.append(destination)
        }
        
        func navigateBackForSecondNavigation() {
            secondNavigationPath.removeLast()
        }
        
        func navigateToSecondRoot() {
            secondNavigationPath.removeLast(secondNavigationPath.count)
        }
        
        func navigateForFirstNavigation(to destination: Destination) {
            firstNavigationPath.append(destination)
        }
        
        func navigateBackForFirstNavigation() {
            firstNavigationPath.removeLast()
        }
        
        func navigateToFirstRoot() {
            firstNavigationPath.removeLast(firstNavigationPath.count)
        }
    }
}


// TODO: Will create separate files for all these Views

struct ParticularSettingsDetails: View {
    let settings: Settings
    
    var body: some View {
        VStack {
            Image(systemName: settings.image)
                .resizable()
                .frame(width: 80, height: 80)
            Text(settings.title)
                .font(.headline)
        }
    }
}

struct AboutWalletView: View {
    var body: some View {
        Text("AboutWallet View")
            .font(.headline)
    }
}

struct HelpView: View {
    var body: some View {
        VStack {
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 80)
                .foregroundStyle(.blue)
            
            Text("HelpView")
                .font(.largeTitle)
        }
    }
}

struct InvestmentView: View {
    var body: some View {
        HStack {
            Image(systemName: "singaporedollarsign.bank.building.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.cyan)
            Text("Investment  View")
                .textScale(.secondary)
        }.padding()
    }
}
