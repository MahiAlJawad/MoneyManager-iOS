//
//  UIViewExtensions.swift
//  MoneyManager-iOS
//
//  Created by Codex on 18/4/26.
//

import UIKit

extension UIView {
    func enclosingSubview<T: UIView>(of type: T.Type) -> T? {
        var container: UIView? = self
        
        while let view = container {
            if let match = view.firstSubview(of: type) {
                return match
            }
            
            container = view.superview
        }
        
        return nil
    }
    
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }
        
        for subview in subviews {
            if let match = subview.firstSubview(of: type) {
                return match
            }
        }
        
        return nil
    }
}
