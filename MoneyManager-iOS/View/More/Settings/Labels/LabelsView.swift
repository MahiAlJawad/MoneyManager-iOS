//
//  LabelsView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 6/11/24.
//

import SwiftData
import SwiftUI

struct LabelsView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var labels: [TransactionLabel]
    
    @State private var searchText: String = ""
    
    var filteredLabels: [TransactionLabel] {
        labels.filter {
            guard !searchText.isEmpty else { return true }
            return $0.name.localizedStandardContains(searchText)
        }
    }
    
    var labelsList: some View {
        List {
            ForEach(filteredLabels) { label in
                HStack {
                    Color(hex: label.color)
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal)
                    Text(label.name)
                }
                .applyListItemHeight()
            }
        }
    }
    
    var body: some View {
        labelsList
            .navigationTitle("Labels")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Dummy code to test label addition
                        let label = TransactionLabel(name: "Dummy label \(Int.random(in: 1...100))", color: "#cb534f")
                        modelContext.insert(label)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    
                }
            }
    }
}

#Preview {
    LabelsView()
}
