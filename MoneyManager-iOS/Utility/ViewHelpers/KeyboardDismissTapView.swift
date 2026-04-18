//
//  KeyboardDismissTapView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 18/4/26.
//

import SwiftUI
import UIKit

struct KeyboardDismissTapView: UIViewRepresentable {
    let onTap: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onTap = onTap
        
        DispatchQueue.main.async {
            context.coordinator.attachRecognizer(to: uiView.window)
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.detachRecognizer()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onTap: () -> Void
        private weak var attachedView: UIView?
        private lazy var recognizer: UITapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            return recognizer
        }()
        
        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }
        
        func attachRecognizer(to view: UIView?) {
            guard let view, attachedView !== view else {
                return
            }
            
            detachRecognizer()
            view.addGestureRecognizer(recognizer)
            attachedView = view
        }
        
        func detachRecognizer() {
            attachedView?.removeGestureRecognizer(recognizer)
            attachedView = nil
        }
        
        @objc func handleTap() {
            onTap()
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            
            while let currentView = view {
                if currentView is UIControl || currentView is UITextView {
                    return false
                }
                
                view = currentView.superview
            }
            
            return true
        }
    }
}
