//
//  ExportDataView.swift
//  MoneyManager-iOS
//
//  Created by Kazi Tanjim Shakib on 20/04/25.
//

import SwiftUI

struct ExportDataView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "square.and.arrow.up.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                
                Text("Export Data")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose a format to export your financial data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 12) {
                exportOptionButton(
                    icon: "doc.fill",
                    title: "CSV",
                    subtitle: "Spreadsheet format",
                    iconColor: .green
                )
                
                exportOptionButton(
                    icon: "doc.pdf.fill",
                    title: "PDF",
                    subtitle: "Document format",
                    iconColor: .red
                )
            }
            .padding(.vertical, 20)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exportOptionButton(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color
    ) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(iconColor)
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
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ExportDataView()
    }
}
