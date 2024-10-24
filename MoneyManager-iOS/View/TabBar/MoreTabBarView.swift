//
//  MoreTabBarView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 13/10/24.
//

import SwiftUI

struct MoreTabBarView: View {
    @State var router = Router()
    @State var addCurrencyPresent: Bool = false
    @State private var savedCurrencies = UserDefaults.standard.object(forKey:"SavedCurrencies") as? [String] ?? [String]()
    
    var body: some View {
        NavigationStack(path: $router.path) {
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
                    CurrencyView(isAddCurrencyPresent: $addCurrencyPresent)
                        .sheet(isPresented: $addCurrencyPresent) {
                            NavigationStack(path: $router.path2) {
                                AddCurrencyView(savedCurrencies: $savedCurrencies)
                                    .navigationDestination(for: Router.Destination2.self) { destination2 in
                                        switch destination2 {
                                        case .currencyConversionView(let selectedCurrency):
                                            let baseCurrencyCode = Locale.current.currency?.identifier ?? ""
                                            
                                            CurrencyDetailsView(currentCurrencies: [baseCurrencyCode, selectedCurrency], savedCurrencies: $savedCurrencies)
                                        case .checkView2:
                                            Text("qwegghh")
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

extension MoreTabBarView {
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
        
        var path = NavigationPath()
        var path2 = NavigationPath()
        
        public enum Destination2: Hashable {
            case currencyConversionView(selectedCurrency: String)
            case checkView2
        }
        
        func navigate2(to destination: Destination2) {
            path2.append(destination)
        }
        
        func navigateBack2() {
            path2.removeLast()
        }
        
        func navigateToRoot2() {
            path2.removeLast()
        }
        
        func navigate(to destination: Destination) {
            path.append(destination)
        }
        
        func navigateBack() {
            path.removeLast()
        }
        
        func navigateToRoot() {
            path.removeLast()
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
