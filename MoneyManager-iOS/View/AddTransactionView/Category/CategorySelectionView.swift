//
//  CategorySelectionView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//
import SwiftUI

struct Category: Identifiable {
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

struct CategorySelectionView: View {
    @State private var searchText: String = ""
    @Binding var selectedCategory: String?

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                }

                if searchText.isEmpty {
                    // Most Frequent Categories when there's no search text
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MOST FREQUENT")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(allCategories.prefix(4)) { category in
                                    VStack {
                                        Circle()
                                            .fill(category.color)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: category.icon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(.white)
                                            )
                                        Text(category.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    

                    // All Categories List when there's no search text
                    VStack(alignment: .leading, spacing: 10) {
                        List(allCategories) { category in
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
                                
                                Text(category.name)
                                    .font(.body)
                                
                                Spacer()
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    .padding(.top)
                } else {
                    // Filtered Categories List when searching
                    List(filteredCategories) { category in
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

                            Spacer()
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                Spacer()
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CategorySelectionView(selectedCategory: .constant("Transportation"))
}
