//
//  CategorySelectionView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//

import SwiftUI

struct CategorySelectionView: View {
    @State private var searchText: String = ""
    @Binding var selectedCategory: Category?
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return Category.allCategories
        } else {
            return Category.allCategories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            List(filteredCategories) { category in
                NavigationLink(destination: CategoryDetailsView(category: category, selectedCategory: $selectedCategory)) {
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
                            if !category.parentCategory.isEmpty {
                                Text(category.parentCategory)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }.modifier(ListItemHeightModifier())
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .textInputAutocapitalization(.never)
            .overlay(alignment: .center) {
                if !searchText.isEmpty && filteredCategories.isEmpty {
                    ContentUnavailableView("Search result not found", systemImage: "magnifyingglass.circle.fill")
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
}
