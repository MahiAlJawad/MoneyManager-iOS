//
//  SegmentedPickerTintUpdater.swift
//  MoneyManager-iOS
//
//  Created by Codex on 18/4/26.
//

import SwiftUI
import UIKit

struct SegmentedPickerTintUpdater: UIViewRepresentable {
    let tintColor: Color
    
    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let segmentedControl = uiView.enclosingSubview(of: UISegmentedControl.self) else {
                return
            }
            
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
            
            UIView.animate(withDuration: 0.2) {
                segmentedControl.selectedSegmentTintColor = UIColor(tintColor)
            }
        }
    }
}
