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
                                        case .checkView1:
                                            checkView()
                                        case .checkView2:
                                            Text("qwegghh")
                                        }
                                    }
                            }
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
            case checkView1
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


struct checkView: View {
    var colors = ["BDT", "USD"]
    
   // let currency: Currency
    @State private var selectedColor = "USD"
    @State private var defaultValue: String = "120.3"
    var body: some View {
        Spacer()
        VStack {
            Picker("picker", selection: $selectedColor) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            Text("selected number is \(selectedColor)")
            CustomKeypad(displayedNumber: $defaultValue)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("back") {
                    print("back button tapped")
                }
            }
        }
    }
}

struct CustomKeypad: View {
    @Binding var displayedNumber: String
    @State private var numericValue: Double? = 0.0
    
    let buttons = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
    ]
    
    var body: some View {
        VStack {
            Spacer()
            //Text(numericValue)
            
            Text(displayedNumber)
                .font(.largeTitle)
                .frame(height: 30)
            
            Spacer()
            
            Grid {
                ForEach(0..<buttons.count, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(buttons[rowIndex], id: \.self) { number in
                            Keypadbutton(label: number) {
                                displayedNumber += number
                                
                                print("shakib1 \(Double(displayedNumber))")
                            }
                        }
                    }
                }
                
                GridRow {
                    Keypadbutton(label: ".") {
                        displayedNumber += "."
                    }
                    Keypadbutton(label: "0") {
                        displayedNumber += "0"
                    }
                    DeleteButton {
                        if !displayedNumber.isEmpty {
                            displayedNumber.removeLast()
                        }
                    }
                }
            }
        }
    }
}

struct Keypadbutton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.gray, in: Circle())
        }
        
    }
}

struct DeleteButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.gray, in: Circle())
                .tint(.primary)
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
        }.padding()
    }
}
