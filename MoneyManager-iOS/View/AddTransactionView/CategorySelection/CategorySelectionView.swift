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
    
    /*
     This is only iOS 18 issue. Workaround solution is used.
     https://stackoverflow.com/questions/79012075/issue-with-swiftui-navigationstack-searchable-modifier-and-returning-to-root-v
     Will update when Apple fix their bug.
     */
    @State var showThisView: Bool = true
    
    var filteredCategories: [Transaction.MainCategory] {
        if searchText.isEmpty {
            return Transaction.allMainCategories
        } else {
            return Transaction.allMainCategories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack {
            if showThisView {
                List(filteredCategories) { category in
                    NavigationLink(value: TransactionTabView.Router.Destination.categoryDetailsView(
                        category: category,
                        selectedCategory: $selectedCategory
                    )) {
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
                    }.applyListItemHeight()
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
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            showThisView = true
        }
        .onDisappear {
            showThisView = false
        }
    }
}
