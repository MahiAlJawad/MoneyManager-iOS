//
//  FinanceBotTransactionParser.swift
//  MoneyManager-iOS
//
//  Created by Codex on 16/5/26.
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct FinanceBotTransactionDraft: Identifiable {
    let id = UUID()
    var sourceText: String
    var transactionType: Transaction.TransactionType
    var amount: String?
    var account: Account?
    var transferAccount: Account?
    var category: Category?
    var date: Date
    var note: String
    var missingFields: [String]
    
    var addTransactionInfo: AddTransactionView.AddTransactionInfo {
        var info = AddTransactionView.AddTransactionInfo(
            transactionType: transactionType,
            account: account
        )
        info.amount = amount ?? ""
        info.transferAccount = transferAccount
        info.category = transactionType == .transfer ? nil : category
        info.date = date
        info.note = note
        return info
    }
}

enum FinanceBotTransactionParser {
    static func parse(
        _ message: String,
        accounts: [Account],
        categories: [Category],
        calendar: Calendar = .current
    ) async -> FinanceBotTransactionDraft {
#if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let generatedDraft = try await foundationModelDraft(
                    message,
                    accounts: accounts,
                    categories: categories
                )
                
                return resolvedDraft(
                    from: generatedDraft,
                    sourceText: message,
                    accounts: accounts,
                    categories: categories,
                    calendar: calendar
                )
            } catch {
                return heuristicDraft(
                    from: message,
                    accounts: accounts,
                    categories: categories,
                    calendar: calendar
                )
            }
        }
#endif
        
        return heuristicDraft(
            from: message,
            accounts: accounts,
            categories: categories,
            calendar: calendar
        )
    }
    
    private static func heuristicDraft(
        from message: String,
        accounts: [Account],
        categories: [Category],
        calendar: Calendar
    ) -> FinanceBotTransactionDraft {
        let normalizedMessage = normalized(message)
        let transactionType = inferredTransactionType(from: normalizedMessage)
        let amount = extractedAmount(from: normalizedMessage)
        let account = matchedAccount(in: normalizedMessage, accounts: accounts, role: .source)
        let transferAccount = transactionType == .transfer
            ? matchedAccount(in: normalizedMessage, accounts: accounts, role: .destination, excluding: account)
            : nil
        let category = transactionType == .transfer ? nil : matchedCategory(in: normalizedMessage, categories: categories)
        let date = inferredDate(from: normalizedMessage, calendar: calendar)
        let missingFields = missingFields(
            transactionType: transactionType,
            amount: amount,
            account: account,
            transferAccount: transferAccount,
            category: category
        )
        
        return FinanceBotTransactionDraft(
            sourceText: message,
            transactionType: transactionType,
            amount: amount,
            account: account,
            transferAccount: transferAccount,
            category: category,
            date: date,
            note: cleanedNote(from: message),
            missingFields: missingFields
        )
    }
    
#if canImport(FoundationModels)
    @available(iOS 26.0, *)
#endif
    private static func resolvedDraft(
        from generatedDraft: GeneratedTransactionDraft,
        sourceText: String,
        accounts: [Account],
        categories: [Category],
        calendar: Calendar
    ) -> FinanceBotTransactionDraft {
        let fallback = heuristicDraft(
            from: sourceText,
            accounts: accounts,
            categories: categories,
            calendar: calendar
        )
        let normalizedSource = normalized(sourceText)
        let transactionType = transactionType(from: generatedDraft.transactionType) ?? fallback.transactionType
        let amount = formattedAmount(from: generatedDraft.amountExpression ?? generatedDraft.amount) ?? fallback.amount
        let account = matchAccount(named: generatedDraft.accountName, accounts: accounts)
            ?? matchedAccount(in: normalizedSource, accounts: accounts, role: .source)
        let transferAccount = transactionType == .transfer
            ? matchAccount(named: generatedDraft.transferAccountName, accounts: accounts, excluding: account)
                ?? matchedAccount(in: normalizedSource, accounts: accounts, role: .destination, excluding: account)
            : nil
        let category = transactionType == .transfer
            ? nil
            : matchCategory(named: generatedDraft.categoryName, categories: categories)
                ?? fallback.category
        let note = generatedDraft.note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? fallback.note
        let date = date(from: generatedDraft.dateHint, calendar: calendar) ?? fallback.date
        let missingFields = missingFields(
            transactionType: transactionType,
            amount: amount,
            account: account,
            transferAccount: transferAccount,
            category: category
        )
        
        return FinanceBotTransactionDraft(
            sourceText: sourceText,
            transactionType: transactionType,
            amount: amount,
            account: account,
            transferAccount: transferAccount,
            category: category,
            date: date,
            note: note,
            missingFields: missingFields
        )
    }
    
    private static func inferredTransactionType(from text: String) -> Transaction.TransactionType {
        if text.containsAny(of: ["transfer", "transferred", "move ", "moved", "sent from", "from "]) &&
            text.contains(" to ") {
            return .transfer
        }
        
        if text.containsAny(of: ["income", "salary", "got paid", "received", "earned", "deposit", "credited"]) {
            return .income
        }
        
        return .expense
    }
    
    private static func transactionType(from text: String?) -> Transaction.TransactionType? {
        guard let text = text.map(normalized) else { return nil }
        
        if text.contains("transfer") { return .transfer }
        if text.contains("income") { return .income }
        if text.contains("expense") { return .expense }
        
        return nil
    }
    
    private static func extractedAmount(from text: String) -> String? {
        let expressionPattern = #"\d+(?:\.\d+)?(?:\s*[+\-*/]\s*\d+(?:\.\d+)?)*"#
        guard let range = text.range(of: expressionPattern, options: .regularExpression) else {
            return nil
        }
        
        return formattedAmount(from: String(text[range]))
    }
    
    private static func formattedAmount(from text: String?) -> String? {
        guard let text else { return nil }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.+-*/")
        let expression = text
            .unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()
        
        return AmountExpressionCalculator.evaluatedAmountValue(from: expression).nilIfEmpty
    }
    
    private enum AccountRole {
        case source
        case destination
    }
    
    private static func matchedAccount(
        in text: String,
        accounts: [Account],
        role: AccountRole,
        excluding excludedAccount: Account? = nil
    ) -> Account? {
        let candidateText: String
        switch role {
        case .source:
            candidateText = text.firstCapturedGroup(for: #"from\s+(.+?)(?:\s+to\s+|$)"#) ?? text
        case .destination:
            candidateText = text.firstCapturedGroup(for: #"\bto\s+(.+)$"#) ?? text
        }
        
        return matchAccount(named: candidateText, accounts: accounts, excluding: excludedAccount)
    }
    
    private static func matchAccount(
        named name: String?,
        accounts: [Account],
        excluding excludedAccount: Account? = nil
    ) -> Account? {
        guard let name = name.map(normalized), !name.isEmpty else { return nil }
        
        return accounts
            .filter { $0.id != excludedAccount?.id }
            .max { score(name, against: normalized($0.name)) < score(name, against: normalized($1.name)) }
            .flatMap { score(name, against: normalized($0.name)) >= 2 ? $0 : nil }
    }
    
    private static func matchedCategory(in text: String, categories: [Category]) -> Category? {
        if text.containsAny(of: ["food", "lunch", "dinner", "breakfast", "meal", "restaurant"]) {
            return matchCategory(named: "Restaurant", categories: categories)
        }
        
        if text.containsAny(of: ["grocery", "groceries", "market", "super shop"]) {
            return matchCategory(named: "Groceries", categories: categories)
        }
        
        if text.containsAny(of: ["bus", "taxi", "uber", "ride", "fuel", "transport"]) {
            return matchCategory(named: text.contains("fuel") ? "Fuel" : "Transportation", categories: categories)
        }
        
        if text.containsAny(of: ["rent", "house", "home", "internet", "utility"]) {
            return matchCategory(named: text.contains("internet") ? "Internet" : "Housing", categories: categories)
        }
        
        if text.containsAny(of: ["phone", "mobile", "recharge"]) {
            return matchCategory(named: "Phone", categories: categories)
        }
        
        if text.containsAny(of: ["shopping", "clothes", "shoe", "gift"]) {
            return matchCategory(named: text.contains("gift") ? "Gifts" : "Shopping", categories: categories)
        }
        
        return matchCategory(named: text, categories: categories)
    }
    
    private static func matchCategory(named name: String?, categories: [Category]) -> Category? {
        guard let name = name.map(normalized), !name.isEmpty else { return nil }
        
        return categories
            .max { score(name, against: normalized($0.name)) < score(name, against: normalized($1.name)) }
            .flatMap { score(name, against: normalized($0.name)) >= 2 ? $0 : nil }
    }
    
    private static func inferredDate(from text: String, calendar: Calendar) -> Date {
        if text.contains("yesterday") {
            return calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        }
        
        if text.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }
        
        return Date()
    }
    
    private static func date(from hint: String?, calendar: Calendar) -> Date? {
        guard let hint = hint.map(normalized), !hint.isEmpty else { return nil }
        
        if hint.contains("today") { return Date() }
        if hint.contains("yesterday") {
            return calendar.date(byAdding: .day, value: -1, to: Date())
        }
        if hint.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: Date())
        }
        
        return nil
    }
    
    private static func missingFields(
        transactionType: Transaction.TransactionType,
        amount: String?,
        account: Account?,
        transferAccount: Account?,
        category: Category?
    ) -> [String] {
        var fields: [String] = []
        
        if amount == nil { fields.append("amount") }
        if account == nil { fields.append(transactionType == .transfer ? "from account" : "account") }
        
        if transactionType == .transfer {
            if transferAccount == nil { fields.append("to account") }
        } else if category == nil {
            fields.append("category")
        }
        
        return fields
    }
    
    private static func cleanedNote(from message: String) -> String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func score(_ source: String, against candidate: String) -> Int {
        if source == candidate { return 10 }
        if source.contains(candidate) || candidate.contains(source) { return 6 }
        
        let sourceWords = Set(source.split(separator: " ").map(String.init))
        let candidateWords = Set(candidate.split(separator: " ").map(String.init))
        return sourceWords.intersection(candidateWords).count * 2
    }
    
    private static func normalized(_ text: String) -> String {
        text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
private extension FinanceBotTransactionParser {
    static func foundationModelDraft(
        _ message: String,
        accounts: [Account],
        categories: [Category]
    ) async throws -> GeneratedTransactionDraft {
        let model = SystemLanguageModel.default
        guard model.isAvailable else {
            throw FinanceBotParserError.modelUnavailable
        }
        
        let session = LanguageModelSession(
            instructions: """
            You extract one personal finance transaction from the user's message.
            Return nil for any missing or uncertain field.
            Use transactionType as exactly one of: expense, income, transfer.
            Use only the provided account and category names. Do not invent names.
            For transfers, put the source account in accountName and destination in transferAccountName.
            If the user gives math for the amount, preserve it in amountExpression.
            """
        )
        let prompt = """
        User message:
        \(message)
        
        Available accounts:
        \(accounts.map(\.name).joined(separator: ", "))
        
        Available categories:
        \(categories.map(\.name).joined(separator: ", "))
        """
        let response = try await session.respond(
            to: prompt,
            generating: GeneratedTransactionDraft.self
        )
        
        return response.content
    }
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedTransactionDraft {
    @Guide(description: "expense, income, transfer, or nil if unknown")
    let transactionType: String?
    
    @Guide(description: "The transaction amount as text, or nil if missing")
    let amount: String?
    
    @Guide(description: "A math expression for the amount, such as 120+80, or nil")
    let amountExpression: String?
    
    @Guide(description: "Closest provided source account name, or nil")
    let accountName: String?
    
    @Guide(description: "Closest provided destination account name for transfer, or nil")
    let transferAccountName: String?
    
    @Guide(description: "Closest provided category name for expense or income, or nil")
    let categoryName: String?
    
    @Guide(description: "Natural language date hint, such as today or yesterday, or nil")
    let dateHint: String?
    
    @Guide(description: "Short note preserving useful user context, or nil")
    let note: String?
}
#else
private struct GeneratedTransactionDraft {
    let transactionType: String?
    let amount: String?
    let amountExpression: String?
    let accountName: String?
    let transferAccountName: String?
    let categoryName: String?
    let dateHint: String?
    let note: String?
}
#endif

private enum FinanceBotParserError: Error {
    case modelUnavailable
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    func containsAny(of needles: [String]) -> Bool {
        needles.contains { contains($0) }
    }
    
    func firstCapturedGroup(for pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: self) else {
            return nil
        }
        
        return String(self[range])
    }
}
