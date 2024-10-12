//
//  CategoryDetailsView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 10/10/24.
//

import SwiftUI

struct CategoryDetailsView: View {
    let category: Category
    
    var body: some View {
        VStack {
            Text("\(category.name)")
            Image(systemName: category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(category.color)
        }.padding()
    }
}

