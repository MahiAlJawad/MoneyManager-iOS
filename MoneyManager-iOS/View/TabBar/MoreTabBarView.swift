//
//  MoreTabBarView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 13/10/24.
//

import SwiftUI

struct MoreTabBarView: View {
    @State var router = Router()
    
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
                }
            }
        }
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
                }
            }
        }
        
        var path = NavigationPath()
        
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
