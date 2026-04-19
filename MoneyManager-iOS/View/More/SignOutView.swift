//
//  SignOutView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 20/04/25.
//

import SwiftUI

struct SignOutView: View {
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "arrow.right.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.red)
                
                Text("Sign Out")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Are you sure you want to sign out from your account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 12) {
                signOutInfoRow(
                    icon: "exclamationmark.circle.fill",
                    title: "Your data will be secure",
                    subtitle: "All your transaction data will remain safe",
                    color: .orange
                )
                
                signOutInfoRow(
                    icon: "checkmark.circle.fill",
                    title: "You can sign in anytime",
                    subtitle: "Access your account whenever you want",
                    color: .green
                )
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: { showConfirmation = true }) {
                    Text("Sign Out")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Button(action: {}) {
                    Text("Cancel")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Sign Out")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Confirm Sign Out", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                // Implement actual sign out logic here
            }
        } message: {
            Text("You will need to sign in again to access your account.")
        }
    }
    
    private func signOutInfoRow(
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        SignOutView()
    }
}
