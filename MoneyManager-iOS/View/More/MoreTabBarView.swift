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
            MoreView().navigationDestination(for: Router.Destination.self) { destination in
                switch destination {
                case .settingsView:
                    SettingsView()
                case .aboutWalletView:
                    AboutWalletView()
                case .recordsView:
                    RecordsView()
                case .investmentsView:
                    InvestmentView()
                case .helpView:
                    HelpView()
                }
            }
        }
    }
}

extension MoreTabBarView {
    @Observable
    final class Router {
        public enum Destination: Codable, Hashable {
            case settingsView
            case aboutWalletView
            case recordsView
            case investmentsView
            case helpView
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

struct SettingsView: View {
    var body: some View {
        HStack {
            Image(systemName: "gear")
                .resizable()
                .frame(width: 50,height: 50)
            Text("Settings View")
                .fontWeight(.bold)
        }
        .padding(50)
        
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

struct RecordsView: View {
    var body: some View {
        VStack {
            Image(systemName: "lock.desktopcomputer")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Records View")
                .font(.subheadline)
        }.padding()
    }
}
