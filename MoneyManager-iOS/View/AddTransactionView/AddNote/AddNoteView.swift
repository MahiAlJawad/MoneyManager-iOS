//
//  AddNoteView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 9/10/24.
//

import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: String
    
    var body: some View {
        VStack {
            TextEditor(text: $notes)
                .font(.body)
                .foregroundColor(.primary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(maxHeight: 250)
                .multilineTextAlignment(.center)
                .toolbar {
                    ToolbarItem {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            Text("TBD")
            Spacer()
        }
        .navigationTitle("Add Notes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddNoteView(notes: .constant(""))
}
