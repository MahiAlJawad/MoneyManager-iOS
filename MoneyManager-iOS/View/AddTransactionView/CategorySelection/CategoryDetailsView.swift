//
//  CategoryDetailsView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 10/10/24.
//

import SwiftUI

struct CategoryDetailsView: View {
    let category: Category
    @Environment(TransactionTabView.Router.self) private var router
    @Binding var selectedCategory: Category?
    
    var body: some View {
        Form {
            CategoryCellView(category: category)
                .makeFullWidthListItemTappable() {
                    selectedCategory = category
                    router.navigateToRoot()
                }
                .applyListItemHeight()
            
            Section(header: Text("Subcategories")) {
                List(category.subCategories) { subcategory in
                    CategoryCellView(category: subcategory)
                        .makeFullWidthListItemTappable() {
                            selectedCategory = subcategory
                            router.navigateToRoot()
                        }
                }.applyListItemHeight()
            }
        }
    }
}

struct CategoryCellView: View {
    let category: Category
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.body)
            }
        }
    }
}
