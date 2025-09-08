//
//  String+Monext.swift
//  Monext
//
//  Created by Joshua Pierce on 22/11/2024.
//

import Foundation

// MARK: - String

extension String {
    
    // formatting helper for chunking card numbers into groups
    // NOTE: [editing problem](https://developer.apple.com/forums/thread/743386)
    func chunked(into size: Int, separator: String = " ") -> String {
        var result: [String] = []
        var currentChunk = ""
        for (index, char) in self.enumerated() {
            currentChunk.append(char)
            if (index + 1) % size == 0 {
                result.append(currentChunk)
                currentChunk = ""
            }
        }
        if !currentChunk.isEmpty {
            result.append(currentChunk)
        }
        return result.joined(separator: separator)
    }
    
    // removes all non-digit characters
    func restrictToNumericInput() -> String {
        self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
    
    // Luhn's Algorithm for card correctness validation
    func passesLuhnCheck() -> Bool {
        
        let reversedDigits = self.reversed().compactMap { Int(String($0)) }
        var sum = 0
        var isOdd = true
        
        for digit in reversedDigits {
            if isOdd {
                sum += digit
            } else {
                let doubled = digit * 2
                sum += (doubled > 9) ? (doubled - 9) : doubled
            }
            isOdd.toggle()
        }
        
        return sum % 10 == 0
    }
    
}

// MARK: - DateFormatter

extension DateFormatter {
    
    static let cardPresentationFormat = {
        let df = DateFormatter()
        df.dateFormat = "MM / yy"
        return df
    }()
    
    static let cardNetworkFormat = {
        let df = DateFormatter()
        df.dateFormat = "MMyy"
        return df
    }()
}
