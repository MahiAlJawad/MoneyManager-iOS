//
//  LabelSelectionView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 20/11/24.
//

import SwiftData
import SwiftUI

struct LabelSelectionView: View {
    @Environment(TransactionTabView.Router.self) private var router
    
    @Query(sort: [.init(\TransactionLabel.name)]) private var labels: [TransactionLabel]
    @Binding var selectedLabels: [TransactionLabel]
    
    private func isLabelSelected(_ label: TransactionLabel) -> Bool {
        selectedLabels.contains(label)
    }
    
    var addLabelButton: some View {
        Button {
            router.navigate(to: .addLabelView)
        } label: {
            Text("Add Label")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 35)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
    }
    
    var noLabelsView: some View {
        VStack {
            Spacer()
            
            Text("No labels available yet. Please add some labels.")
                .font(.title3)
            Button {
                router.navigate(to: .addLabelView)
            } label: {
                Text("Add Label")
            }
            .padding()
            
            Spacer()
        }
    }
    
    var labelsList: some View {
        List {
            if labels.isEmpty {
                noLabelsView
                    .frame(minHeight: 650)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(labels) { label in
                    HStack {
                        Color(hex: label.color)
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.horizontal)
                        Text(label.name)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .opacity(isLabelSelected(label) ? 1.0 : 0.0)
                    }
                    .applyListItemHeight()
                    .makeFullWidthListItemTappable() {
                        if isLabelSelected(label) {
                            guard let index = selectedLabels.firstIndex(of: label) else {
                                return
                            }
                            selectedLabels.remove(at: index)
                        } else {
                            selectedLabels.append(label)
                        }
                    }
                }
                
                Button {
                    router.navigate(to: .addLabelView)
                } label: {
                    Label("Add Label", systemImage: "plus.circle.fill")
                        .padding(.horizontal)
                }
                .applyListItemHeight()
            }
        }
    }
    
    var body: some View {
        labelsList
            .navigationTitle("Select Labels")
    }
}
