//
//  SettingsTabView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 13/10/24.
//

import SwiftUI

struct SettingsTabView: View {
    @Observable
    class SheetPresentation {
        var presentAddCurrency: Bool = false
    }
    
    @State var router = Router()
    @State var sheetPresenter = SheetPresentation()
    @State var savedCurrencies: [Currency] = []
    
    var body: some View {
        NavigationStack(path: $router.firstNavigationPath) {
            SettingsView()
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .settingsView:
                        SettingsDetails()
                    case .aboutWalletView:
                        AboutWalletView()
                    case .recordsView:
                        AllTransactionView()
                    case .investmentsView:
                        InvestmentView()
                    case .helpView:
                        HelpView()
                    case .particularSettingsView(let settings):
                        ParticularSettingsDetails(settings: settings)
                    case .currencyView:
                        CurrencyView(
                            isAddCurrencyPresent: $sheetPresenter.presentAddCurrency,
                            savedCurrencies: $savedCurrencies
                        )
                        .onAppear {
                            savedCurrencies = Currency.loadCurrencyData()
                        }
                        .sheet(isPresented: $sheetPresenter.presentAddCurrency) {
                            NavigationStack(path: $router.secondNavigationPath) {
                                AddCurrencyView(
                                    isSheetPresented: $sheetPresenter.presentAddCurrency,
                                    newCurrencies: $savedCurrencies
                                )
                                .navigationDestination(for: Router.Destination2.self) { destination2 in
                                    switch destination2 {
                                    case .currencyConversionView(let selectedCurrency):
                                        let baseCurrencyCode = Currency.baseCurrencyCode
                                        
                                        CurrencyDetailsView(
                                            currentCurrencies: [baseCurrencyCode, selectedCurrency],
                                            decimalPlaces: Currency.loadDecimalPlaces(),
                                            onSaveCompletion: {
                                                sheetPresenter.presentAddCurrency = false
                                            }, 
                                            savedNewCurrencies: $savedCurrencies
                                        )
                                    }
                                }
                            }
                            .environment(router)
                        }
                    case .exportDataView:
                        ExportDataView()
                    case .sendFeedbackView:
                        SendFeedbackView()
                    case .customNotificationView:
                        CustomNotificationView()
                    case .signOutView:
                        SignOutView()
                    }
                }
        }
        .environment(router)
        .environment(sheetPresenter)
    }
}

extension SettingsTabView {
    @Observable
    final class Router {
        enum Destination: Hashable {
            case settingsView
            case aboutWalletView
            case recordsView
            case investmentsView
            case helpView
            case particularSettingsView(settings: Settings)
            case currencyView
            case exportDataView
            case sendFeedbackView
            case customNotificationView
            case signOutView
        }
        
        var firstNavigationPath = NavigationPath()
        var secondNavigationPath = NavigationPath()
        
        enum Destination2: Hashable {
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
        }
        .padding()
    }
}
