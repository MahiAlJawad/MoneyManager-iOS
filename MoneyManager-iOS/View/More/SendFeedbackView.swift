//
//  SendFeedbackView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 20/04/25.
//

import SwiftUI

struct SendFeedbackView: View {
    @State private var feedbackText: String = ""
    @State private var feedbackType: String = "Bug Report"
    
    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback"]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "message.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.red.opacity(0.85))
                
                Text("Send Feedback")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Help us improve SpendWise by sharing your thoughts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Feedback Type")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Picker("Type", selection: $feedbackType) {
                    ForEach(feedbackTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Feedback")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 120)
                    .padding(10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("Submit Feedback")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SendFeedbackView()
    }
}
