//
//  ArrayExtensions.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 2/11/24.
//

import Foundation

extension Array where Element:Equatable {
    func removeConsecutiveDuplicates() -> [Element] {
        var previousElement: Element? = nil
        return reduce(into: []) { total, element in
            defer {
                previousElement = element
            }
            guard previousElement != element else {
                return
            }
            total.append(element)
        }
    }
}
