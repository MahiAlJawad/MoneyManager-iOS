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
    CategorySelectionView(selectedCategory: .constant(.init(name: "test", icon: "ss", color: .blue, parentCategory: "")))
}
