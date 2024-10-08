//
//  NoteSelectionView.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//

import SwiftUI
import SwiftData

@Model
class NoteText {
    var text: String = ""
    
    init(text: String) {
        self.text = text
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State var noteText: NoteText
    
    var body: some View {
        NavigationStack {
            VStack {
                // Text Editor for note input
                TextEditor(text: $noteText.text)
                    .font(.body)
                    .foregroundColor(noteText.text.isEmpty ? .gray : .primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    
                
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Record") {
                        save()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func save() {
        modelContext.insert(noteText)
    }
}

//#Preview {
//    AddNoteView(data: .constant("hello"))
//}
