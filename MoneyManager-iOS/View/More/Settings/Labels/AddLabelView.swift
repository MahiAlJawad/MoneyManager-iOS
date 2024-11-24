//
//  AddLabelView.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 7/11/24.
//

import SwiftUI

struct AddLabelView: View {
    var isModallyPresented: Bool = false
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var labelInfo = TransactionLabel.LabelInfo()
    @FocusState var isNameFocused: Bool
    
    var isSaveButtonEnabled: Bool {
        !labelInfo.name.isEmpty
    }
    
    var body: some View {
        VStack {
            labelInfoList
            saveButton
        }
        .listStyle(.grouped)
        .navigationTitle("Add Label")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isModallyPresented {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isNameFocused = false
                }
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }
    
    var labelInfoList: some View {
        List {
            Section("General") {
                HStack {
                    Image(systemName: "pencil.and.scribble")
                        .padding(.horizontal)
                    TextField("Label name", text: $labelInfo.name)
                        .focused($isNameFocused)
                }
                .applyListItemHeight()
                HStack {
                    labelInfo.color
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal)
                    ColorPicker("Color", selection: $labelInfo.color)
                }
                .applyListItemHeight()
            }
        }
    }
    
    var saveButton: some View {
        Button {
            TransactionLabel.addLabel(in: modelContext, with: labelInfo)
            dismiss()
        } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 35)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .disabled(!isSaveButtonEnabled)
    }
}

#Preview {
    AddLabelView()
}
