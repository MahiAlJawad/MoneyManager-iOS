//
//  ViewOnLoadModifier.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 13/10/24.
//

import SwiftUI

struct ViewOnLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)

    fileprivate init(perform action: @escaping (() -> Void)) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action()
            }
        }
    }
}

extension View {
    /// This modifier will be only called when the view is loaded
    /// Not in the each time it appears
    /// It can be used as `ViewDidLoad()` alternative in SwiftUI views
    func onLoad(perform action: @escaping (() -> Void)) -> some View {
        modifier(ViewOnLoadModifier(perform: action))
    }
}
