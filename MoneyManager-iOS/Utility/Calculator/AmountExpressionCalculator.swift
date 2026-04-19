//
//  AmountExpressionCalculator.swift
//  MoneyManager-iOS
//
//  Created by Codex on 19/4/26.
//

import Foundation

enum AmountExpressionCalculator {
    static func displayText(for expression: String) -> String {
        expression.isEmpty ? "0" : expression
    }
    
    static func evaluatedAmountValue(from expression: String) -> String {
        let trimmedExpression = expression.trimmingTrailingOperatorsAndDecimal()
        
        guard let value = AmountExpressionEvaluator(expression: trimmedExpression).evaluate(),
              value.isFinite,
              value > 0 else {
            return ""
        }
        
        return formattedNumber(value)
    }
    
    static func appendingDigit(_ digit: String, to expression: String) -> String {
        guard digit.count == 1 else { return expression }
        
        var expression = expression
        let range = currentNumberTokenRange(in: expression)
        let currentToken = String(expression[range])
        
        if currentToken == "0" {
            if digit == "0" {
                return expression
            }
            
            expression.replaceSubrange(range, with: digit)
        } else {
            expression.append(digit)
        }
        
        return expression
    }
    
    static func appendingDecimalPoint(to expression: String) -> String {
        let range = currentNumberTokenRange(in: expression)
        let currentToken = String(expression[range])
        
        guard !currentToken.contains(".") else { return expression }
        
        if currentToken.isEmpty {
            return expression + "0."
        }
        
        return expression + "."
    }
    
    static func appendingOperator(_ operation: String, to expression: String) -> String {
        guard !expression.isEmpty else { return expression }
        
        var expression = expression
        
        if expression.last?.isAmountOperator == true {
            expression.removeLast()
        }
        
        if expression.last != "." {
            expression.append(operation)
        }
        
        return expression
    }
    
    static func applyingPercentToCurrentNumber(in expression: String) -> String {
        var expression = expression
        let range = currentNumberTokenRange(in: expression)
        let currentToken = String(expression[range])
        
        guard let value = Double(currentToken) else { return expression }
        
        expression.replaceSubrange(range, with: formattedNumber(value / 100))
        return expression
    }
    
    static func evaluatedExpression(from expression: String) -> String {
        evaluatedAmountValue(from: expression)
    }
    
    private static func formattedNumber(_ value: Double) -> String {
        let roundedValue = (value * 100_000_000).rounded() / 100_000_000
        var text = String(format: "%.8f", roundedValue)
        
        while text.last == "0" {
            text.removeLast()
        }
        
        if text.last == "." {
            text.removeLast()
        }
        
        return text
    }
    
    private static func currentNumberTokenRange(in expression: String) -> Range<String.Index> {
        let startIndex = expression.lastIndex(where: \.isAmountOperator)
            .map { expression.index(after: $0) } ?? expression.startIndex
        
        return startIndex..<expression.endIndex
    }
}

private struct AmountExpressionEvaluator {
    private let characters: [Character]
    private var index = 0
    
    init(expression: String) {
        characters = Array(expression)
    }
    
    func evaluate() -> Double? {
        var evaluator = self
        guard let value = evaluator.parseExpression(),
              evaluator.index == evaluator.characters.count else {
            return nil
        }
        
        return value
    }
    
    private mutating func parseExpression() -> Double? {
        guard var value = parseTerm() else { return nil }
        
        while let operation = currentCharacter, operation == "+" || operation == "-" {
            advance()
            
            guard let nextValue = parseTerm() else { return nil }
            
            if operation == "+" {
                value += nextValue
            } else {
                value -= nextValue
            }
        }
        
        return value
    }
    
    private mutating func parseTerm() -> Double? {
        guard var value = parseNumber() else { return nil }
        
        while let operation = currentCharacter, operation == "*" || operation == "/" {
            advance()
            
            guard let nextValue = parseNumber() else { return nil }
            
            if operation == "*" {
                value *= nextValue
            } else {
                guard nextValue != 0 else { return nil }
                value /= nextValue
            }
        }
        
        return value
    }
    
    private mutating func parseNumber() -> Double? {
        let startIndex = index
        
        while let character = currentCharacter,
              character.isNumber || character == "." {
            advance()
        }
        
        guard startIndex != index else { return nil }
        
        return Double(String(characters[startIndex..<index]))
    }
    
    private var currentCharacter: Character? {
        guard index < characters.count else { return nil }
        
        return characters[index]
    }
    
    private mutating func advance() {
        index += 1
    }
}

private extension Character {
    var isAmountOperator: Bool {
        self == "+" || self == "-" || self == "*" || self == "/"
    }
}

private extension String {
    func trimmingTrailingOperatorsAndDecimal() -> String {
        var text = self
        
        while let last = text.last,
              last.isAmountOperator || last == "." {
            text.removeLast()
        }
        
        return text
    }
}
