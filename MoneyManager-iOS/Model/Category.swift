//
//  Category.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//
import SwiftUI

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let parentCategory: String
}

// Sample categories data
let allCategories: [Category] = [
    Category(name: "Groceries", icon: "cart.fill", color: .red, parentCategory: "Food & Drinks"),
    Category(name: "Restaurant, fast-food", icon: "fork.knife", color: .red, parentCategory: "Food & Drinks"),
    Category(name: "Food & Drinks", icon: "fork.knife", color: .red, parentCategory: "Food & Drinks"),
    Category(name: "Shopping", icon: "bag", color: .blue, parentCategory: ""),
    Category(name: "Housing", icon: "house", color: .orange, parentCategory: ""),
    Category(name: "Transportation", icon: "car", color: .gray, parentCategory: ""),
    Category(name: "Vehicle", icon: "car.2.fill", color: .purple, parentCategory: ""),
    Category(name: "Life & Entertainment", icon: "gamecontroller", color: .green, parentCategory: ""),
    Category(name: "Communication, PC", icon: "iphone", color: .black, parentCategory: "")
]
