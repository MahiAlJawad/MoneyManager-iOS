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
    @Environment(MoreTabView.SheetPresentation.self) var sheetPresenter
    
    @Query(sort: [.init(\TransactionLabel.name)]) private var labels: [TransactionLabel]
    
    @State private var searchText: String = ""
    
    var filteredLabels: [TransactionLabel] {
        labels.filter {
            guard !searchText.isEmpty else { return true }
            return $0.name.localizedStandardContains(searchText)
        }
    }
    
    var labelsList: some View {
        List {
            if labels.isEmpty {
                VStack {
                    Spacer()
                    Text("No labels available yet. Please add some labels.")
                        .font(.title3)
                    Spacer()
                }
                .frame(minHeight: 650)
                .listRowBackground(Color.clear)
            } else {
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
                .onDelete(perform: deleteLabel)
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
                        sheetPresenter.presentLabelsView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
    }
    
    private func deleteLabel(with indexSet: IndexSet) {
        for index in indexSet {
            filteredLabels[index].deleteLabel(from: modelContext)
        }
    }
}

#Preview {
    LabelsView()
}
