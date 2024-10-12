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
    let subCategories: [Category]
}

// TODO: Sample categories data, will be updated when UI is fixed

let sampleCategory1: Category = .init(name: "Investments", icon: "dollarsign.bank.building", color: .red, parentCategory: "", subCategories: [])
let sampleCategory2: Category = .init(name: "Restaurant", icon: "fork.knife", color: .orange, parentCategory: "", subCategories: [])
let sampleCategory3: Category = .init(name: "Housing", icon: "house", color: .red, parentCategory: "", subCategories: [])
let sampleCategory4: Category = .init(name: "Tranportation", icon: "car", color: .red, parentCategory: "", subCategories: [])
let sampleCategory5: Category = .init(name: "Vehicle", icon: "bus", color: .red, parentCategory: "", subCategories: [])
let sampleCategory6: Category = .init(name: "Shopping", icon: "bag", color: .red, parentCategory: "", subCategories: [])
let sampleCategory7: Category = .init(name: "Gaming", icon: "gamecontroller", color: .red, parentCategory: "", subCategories: [])

let allCategories: [Category] = [
    Category(
        name: "Groceries",
        icon: "cart.fill",
        color: .red,
        parentCategory: "Food & Drinks",
        subCategories: [sampleCategory1,sampleCategory7,sampleCategory5]
    ),
    Category(
        name: "Restaurant, fast-food",
        icon: "fork.knife",
        color: .red,
        parentCategory: "Food & Drinks",
        subCategories: [sampleCategory5,sampleCategory2,sampleCategory3,sampleCategory7]
    ),
    Category(
        name: "Food & Drinks",
        icon: "fork.knife",
        color: .red,
        parentCategory: "Food & Drinks",
        subCategories: [sampleCategory7, sampleCategory1,sampleCategory2,sampleCategory3]
    ),
    Category(
        name: "Shopping",
        icon: "bag",
        color: .blue,
        parentCategory: "",
        subCategories: [sampleCategory4,sampleCategory3,sampleCategory2,sampleCategory1]
    ),
    Category(
        name: "Housing",
        icon: "house",
        color: .orange,
        parentCategory: "",
        subCategories: [sampleCategory7,sampleCategory1,sampleCategory2,sampleCategory3]
    ),
    Category(
        name: "Transportation",
        icon: "car",
        color: .gray,
        parentCategory: "",
        subCategories: [sampleCategory1,sampleCategory5,sampleCategory3,sampleCategory4]
    ),
    Category(
        name: "Vehicle",
        icon: "car.2.fill",
        color: .purple,
        parentCategory: "",
        subCategories: [sampleCategory6,sampleCategory5,sampleCategory3,sampleCategory4]
    ),
    Category(
        name: "Life & Entertainment",
        icon: "gamecontroller",
        color: .green,
        parentCategory: "",
        subCategories: [sampleCategory3,sampleCategory7,sampleCategory2,sampleCategory6]
    ),
    Category(
        name: "Communication, PC",
        icon: "iphone",
        color: .black,
        parentCategory: "",
        subCategories: [sampleCategory6,sampleCategory4,sampleCategory3,sampleCategory2]
    )
]
