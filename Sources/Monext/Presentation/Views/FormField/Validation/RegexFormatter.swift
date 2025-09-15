//
//  RegexFormatter.swift
//  Monext
//
//  Created by SDK Mobile on 28/08/2025.
//

import Foundation

struct RegexFormatter: FormFieldView<String>.Formatter {
        
    private let maxLength: Int?
    private let requiresFullMatch: Bool
    private let preValidationTransform: ((String) -> String)?
    
    private let originalPattern: String
    private let appliedPattern: String
    private let regex: NSRegularExpression?
    
    /// Conserve la dernière erreur de compilation ou d’évaluation (facultatif)
    private(set) var lastError: ErrorKind?
    
    enum ErrorKind: Equatable {
        case invalidPattern(String)
    }
    
    init(
        pattern: String,
        maxLength: Int? = nil,
        requiresFullMatch: Bool = true,
        preValidationTransform: ((String) -> String)? = nil
    ) {
        self.originalPattern = pattern
        self.maxLength = maxLength
        self.requiresFullMatch = requiresFullMatch
        self.preValidationTransform = preValidationTransform
        
        if requiresFullMatch {
            if pattern.hasPrefix("^") && pattern.hasSuffix("$") {
                self.appliedPattern = pattern
            } else {
                self.appliedPattern = "^\(pattern)$"
            }
        } else {
            self.appliedPattern = pattern
        }
        
        if let compiled = try? NSRegularExpression(pattern: appliedPattern, options: []) {
            self.regex = compiled
        } else {
            self.regex = nil
            self.lastError = .invalidPattern(pattern)
        }
    }
    
    // MARK: - Formatter
    
    func preformattedRawValue(_ value: String) -> String {
        var processed = value
        if let transform = preValidationTransform {
            processed = transform(processed)
        }
        if let maxLength {
            processed = String(processed.prefix(maxLength))
        }
        return processed
    }
    
    func format(_ value: String) -> String {
        // Pour l’instant identique; tu peux plus tard y appliquer un masque visuel.
        preformattedRawValue(value)
    }
    
    // MARK: - Validation publique (optionnelle)
    
    func isValid(_ value: String, usePreformatted: Bool = true) -> Bool {
        guard let regex else { return false }
        let target = usePreformatted ? preformattedRawValue(value) : value
        let range = NSRange(target.startIndex..<target.endIndex, in: target)
        return regex.firstMatch(in: target, options: [], range: range) != nil
    }
}
