//
//  FinanceBotView.swift
//  MoneyManager-iOS
//
//  Created by Codex on 16/5/26.
//

import SwiftData
import SwiftUI

struct FinanceBotView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [.init(\Account.name)])
    private var accounts: [Account]
    
    @State private var messageText = ""
    @State private var messages: [FinanceBotMessage] = [
        .init(
            text: "Tell me about a transaction, like \"Spent 450 on lunch from Cash yesterday\". I will prepare the add form for you.",
            isFromBot: true
        )
    ]
    @State private var isPreparingDraft = false
    @State private var presentedDraft: FinanceBotTransactionDraft?
    @State private var transactionRouter = TransactionTabView.Router()

    private let accentColor = Color(hex: "#1F8F63")
    private let examples = [
        "Spent 450 on lunch from Cash yesterday",
        "Got salary 80000 in City Bank",
        "Moved 5000 from Cash to Bank",
        "Paid 120 + 80 for groceries"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    examplesSection
                    placeholderChatSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }

            chatInputBar
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Text("Finance Bot")
                        .font(.headline)
                    
                    Text("Beta")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(accentColor.opacity(0.14), in: Capsule())
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(item: $presentedDraft) { draft in
            NavigationStack {
                AddTransactionView(initialTransactionInfo: draft.addTransactionInfo)
            }
            .environment(transactionRouter)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(accentColor.gradient, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Add by asking")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("Describe an expense, income, or transfer. I will prepare a draft you can review before saving.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try asking")
                .font(.headline)
                .foregroundStyle(Color(uiColor: .label))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 10)], spacing: 10) {
                ForEach(examples, id: \.self) { example in
                    Button {
                        messageText = example
                    } label: {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(accentColor)
                                .padding(.top, 2)

                            Text(example)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(uiColor: .label))
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .minimumScaleFactor(0.9)

                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var placeholderChatSection: some View {
        VStack(spacing: 14) {
            ForEach(messages) { message in
                chatBubble(text: message.text, isFromBot: message.isFromBot)
            }
            
            if isPreparingDraft {
                HStack {
                    ProgressView()
                        .tint(accentColor)
                    
                    Text("Preparing draft...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 4)
    }

    private func chatBubble(text: String, isFromBot: Bool) -> some View {
        HStack {
            if !isFromBot {
                Spacer(minLength: 42)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isFromBot ? Color(uiColor: .label) : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    isFromBot ? Color(uiColor: .secondarySystemGroupedBackground) : accentColor,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )

            if isFromBot {
                Spacer(minLength: 42)
            }
        }
    }

    private var chatInputBar: some View {
        HStack(spacing: 10) {
            TextField("Message FinanceBot", text: $messageText, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .disabled(isPreparingDraft)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(accentColor, in: Circle())
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPreparingDraft)
            .opacity(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPreparingDraft ? 0.45 : 1)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.regularMaterial)
    }
    
    private var allCategories: [Category] {
        Transaction.MainCategory.allCases + Transaction.Subcategory.allCases
    }
    
    private func sendMessage() {
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        messageText = ""
        messages.append(.init(text: userMessage, isFromBot: false))
        isPreparingDraft = true
        
        Task {
            let draft = await FinanceBotTransactionParser.parse(
                userMessage,
                accounts: accounts,
                categories: allCategories
            )
            
            await MainActor.run {
                isPreparingDraft = false
                messages.append(.init(text: responseText(for: draft), isFromBot: true))
                presentedDraft = draft
            }
        }
    }
    
    private func responseText(for draft: FinanceBotTransactionDraft) -> String {
        var lines = [
            "I prepared a \(draft.transactionType.description.lowercased()) draft.",
            "Amount: \(draft.amount ?? "missing")",
            "Account: \(draft.account?.name ?? "missing")"
        ]
        
        if draft.transactionType == .transfer {
            lines.append("To: \(draft.transferAccount?.name ?? "missing")")
        } else {
            lines.append("Category: \(draft.category?.name ?? "missing")")
        }
        
        if !draft.missingFields.isEmpty {
            lines.append("Missing: \(draft.missingFields.joined(separator: ", "))")
        }
        
        lines.append("Review it, then tap Save when it looks right.")
        return lines.joined(separator: "\n")
    }
}

private struct FinanceBotMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromBot: Bool
}

#Preview {
    NavigationStack {
        FinanceBotView()
    }
}
